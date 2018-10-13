# frozen_string_literal: true

module Api
  module V1
    class VehiclesController < ::Api::V1::BaseController
      skip_authorization_check only: %i[public public_count]
      before_action :authenticate_api_user!, except: %i[public public_count]
      after_action -> { pagination_header(:vehicles) }, only: %i[index public]

      def index
        authorize! :index, :api_hangar
        scope = current_user.vehicles

        if price_range.present?
          query_params['sorts'] = 'price asc'
          scope = scope.includes(:model).where(models: { price: price_range })
        end

        if pledge_price_range.present?
          query_params['sorts'] = 'fallback_pledge_price asc'
          scope = scope.includes(:model).where(models: { fallback_pledge_price: pledge_price_range })
        end

        @q = scope.ransack(query_params)

        @q.sorts = ['flagship desc', 'purchased desc', 'name asc', 'model_name asc'] if @q.sorts.empty?

        @vehicles = @q.result(distinct: true)
                      .includes(:model)
                      .joins(:model)
                      .page(params[:page])
                      .per(per_page(Vehicle))
      end

      def fleetchart
        authorize! :index, :api_hangar
        @q = current_user.vehicles
                         .ransack(query_params)

        @q.sorts = ['model_length desc', 'model_name asc']

        @vehicles = @q.result.uniq
      end

      def count
        authorize! :index, :api_hangar
        @q = current_user.vehicles
                         .ransack(query_params)

        @q.sorts = ['model_classification asc']

        vehicles = @q.result
        models = vehicles.map(&:model)

        @count = OpenStruct.new(
          total: vehicles.count,
          classifications: models.map(&:classification).uniq.compact.map do |classification|
            OpenStruct.new(
              count: models.select { |model| model.classification == classification }.count,
              name: classification,
              label: classification.humanize
            )
          end,
          metrics: {
            total_money: models.map(&:fallback_pledge_price).sum(&:to_i),
            total_min_crew: models.map(&:display_min_crew).sum(&:to_i),
            total_max_crew: models.map(&:display_max_crew).sum(&:to_i),
            total_cargo: models.map(&:display_cargo).sum(&:to_i)
          }
        )
      end

      def public
        user = User.find_by!('lower(username) = ?', params.fetch(:username, '').downcase)
        @q = user.vehicles
                 .purchased
                 .ransack(query_params)

        @q.sorts = ['flagship desc', 'purchased desc', 'name asc', 'model_name asc'] if @q.sorts.empty?

        @vehicles = @q.result
                      .page(params[:page])
                      .per(per_page(Vehicle))
      end

      def public_count
        user = User.find_by!('lower(username) = ?', params.fetch(:username, '').downcase)
        models = user.purchased_models

        @count = OpenStruct.new(
          total: models.count,
          classifications: models.map(&:classification).uniq.compact.map do |classification|
            OpenStruct.new(
              count: models.where(classification: classification).count,
              name: classification,
              label: classification.humanize
            )
          end
        )
      end

      def hangar_items
        authorize! :index, :api_hangar
        model_ids = current_user.vehicles.pluck(:model_id)
        @models = Model.where(id: model_ids).order(name: :asc).pluck(:slug)
      end

      def create
        @vehicle = Vehicle.new(vehicle_params)
        authorize! :create, vehicle

        if vehicle.save
          render status: :created
        else
          render json: ValidationError.new('vehicle.create', @vehicle.errors), status: :bad_request
        end
      end

      def update
        authorize! :update, vehicle

        return if vehicle.update(vehicle_params)

        render json: ValidationError.new('vehicle.update', @vehicle.errors), status: :bad_request
      end

      def destroy
        authorize! :destroy, vehicle

        return if vehicle.destroy

        render json: ValidationError.new('vehicle.destroy', @vehicle.errors), status: :bad_request
      end

      private def vehicle
        @vehicle ||= Vehicle.find_by!(id: params[:id])
      end
      helper_method :vehicle

      private def vehicle_params
        @vehicle_params ||= begin
          params.transform_keys(&:underscore)
            .permit(
              :name, :model_id, :purchased, :name_visible,
              :sale_notify, :flagship, hangar_group_ids: []
            ).merge(user_id: current_user.id)
        end
      end

      private def price_range
        @price_range ||= begin
          price_in.map do |prices|
            gt_price, lt_price = prices.split('-')
            gt_price = if gt_price.blank?
                         0
                       else
                         gt_price.to_i
                       end
            lt_price = if lt_price.blank?
                         Float::INFINITY
                       else
                         lt_price.to_i
                       end
            (gt_price...lt_price)
          end
        end
      end

      private def pledge_price_range
        @pledge_price_range ||= begin
          pledge_price_in.map do |prices|
            gt_price, lt_price = prices.split('-')
            gt_price = if gt_price.blank?
                         0
                       else
                         gt_price.to_i
                       end
            lt_price = if lt_price.blank?
                         Float::INFINITY
                       else
                         lt_price.to_i
                       end
            (gt_price...lt_price)
          end
        end
      end

      private def pledge_price_in
        pledge_price_in = query_params.delete('model_pledge_price_in')
        pledge_price_in = pledge_price_in.to_s.split unless pledge_price_in.is_a?(Array)
        pledge_price_in
      end

      private def price_in
        price_in = query_params.delete('model_price_in')
        price_in = price_in.to_s.split unless price_in.is_a?(Array)
        price_in
      end
    end
  end
end
