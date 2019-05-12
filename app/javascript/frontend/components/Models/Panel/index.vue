<template>
  <div>
    <Panel
      v-if="model"
      :id="model.slug"
    >
      <div class="panel-heading">
        <h2 class="panel-title">
          <router-link :to="{ name: 'model', params: { slug: model.slug }}">
            <span v-if="customName">
              {{ customName }}
            </span>
            <span v-else>
              {{ countLabel }}{{ model.name }}
            </span>
          </router-link>
          <small
            v-if="vehicle && vehicle.flagship"
            v-tooltip.right="flagshipTooltip"
          >
            <i class="fa fa-certificate" />
          </small>
          <br>
          <small v-if="customName">
            <router-link
              :to="{ query: { q: filterManufacturerQuery(model.manufacturer.slug) }}"
              v-html="model.manufacturer.name"
            />
            {{ model.name }}
          </small>
          <small v-else>
            <router-link
              :to="{ query: { q: filterManufacturerQuery(model.manufacturer.slug) }}"
              v-html="model.manufacturer.name"
            />
          </small>
          <Btn
            v-if="isMyShip && onEdit"
            :title="t('actions.edit')"
            :aria-label="t('actions.edit')"
            class="panel-edit-button"
            variant="link"
            size="small"
            @click.native="onEdit(vehicle)"
          >
            <i class="fa fa-pencil" />
          </Btn>
          <AddToHangar
            v-else
            :model="model"
            class="panel-add-to-hangar-button"
            variant="panel"
          />
        </h2>
      </div>
      <div
        :class="{
          'no-details': !details,
        }"
        class="panel-image text-center"
      >
        <router-link
          :key="model.storeImageMedium"
          v-lazy:background-image="model.storeImageMedium"
          :to="{ name: 'model', params: { slug: model.slug }}"
          :aria-label="model.name"
          class="lazy"
        >
          <div
            v-if="isMyShip"
            v-show="vehicle.purchased"
            v-tooltip="t('labels.model.purchased')"
            class="purchased"
          >
            <i class="fal fa-check" />
          </div>
          <div
            v-show="model.onSale"
            v-tooltip="t('labels.model.onSale')"
            class="on-sale"
          >
            <i class="fal fa-dollar-sign" />
          </div>
        </router-link>
        <div
          v-if="upgradable && onAddons"
          v-tooltip="t('labels.model.addons')"
          class="addons"
          :class="{
            selected: (vehicle.modelModuleIds.length || vehicle.modelUpgradeIds.length)
          }"
          @click="onAddons(vehicle)"
        >
          <i
            class="fa-plus-octagon"
            :class="{
              far: !(vehicle.modelModuleIds.length || vehicle.modelUpgradeIds.length),
              fa: (vehicle.modelModuleIds.length || vehicle.modelUpgradeIds.length),
            }"
          />
        </div>
      </div>
      <b-collapse
        :id="`details-${model.slug}-wrapper`"
        :visible="details"
      >
        <div class="production-status">
          <strong class="text-uppercase">
            <template v-if="model.productionStatus">
              {{ t(`labels.model.productionStatus.${model.productionStatus}`) }}
            </template>
            <template v-else>
              {{ t(`labels.not-available`) }}
            </template>
          </strong>
        </div>
        <ul class="list-group">
          <li class="list-group-item">
            <ModelTopMetrics :model="model" />
          </li>
          <li class="list-group-item">
            <ModelBaseMetrics :model="model" />
          </li>
        </ul>
      </b-collapse>
    </Panel>
  </div>
</template>

<script>
import I18n from 'frontend/mixins/I18n'
import Panel from 'frontend/components/Panel'
import Btn from 'frontend/components/Btn'
import AddToHangar from 'frontend/partials/Models/AddToHangar'
import ModelTopMetrics from 'frontend/partials/Models/TopMetrics'
import ModelBaseMetrics from 'frontend/partials/Models/BaseMetrics'

export default {
  name: 'ModelPanel',
  components: {
    Panel,
    Btn,
    AddToHangar,
    ModelTopMetrics,
    ModelBaseMetrics,
  },
  mixins: [I18n],
  props: {
    model: {
      type: Object,
      required: true,
    },
    vehicle: {
      type: Object,
      default() {
        return {}
      },
    },
    onEdit: {
      type: Function,
      default() {
        return () => {}
      },
    },
    onAddons: {
      type: Function,
      default() {
        return () => {}
      },
    },
    details: {
      type: Boolean,
      default: false,
    },
    count: {
      type: Number,
      default: null,
    },
  },
  computed: {
    customName() {
      if (this.vehicle && this.vehicle.name && (this.$route.name !== 'hangar-public' || this.vehicle.nameVisible)) {
        return this.vehicle.name
      }
      return null
    },
    countLabel() {
      if (!this.count) {
        return ''
      }
      return `${this.count}x `
    },
    flagshipTooltip() {
      if (!this.vehicle) {
        return ''
      }
      if (this.$route.name === 'hangar') {
        return this.t('labels.yourFlagship')
      }
      return this.t('labels.flagship')
    },
    isMyShip() {
      return this.vehicle && this.onEdit
    },
    upgradable() {
      return this.isMyShip && (this.model.hasModules || this.model.hasUpgrades)
    },
  },
  methods: {
    filterManufacturerQuery(manufacturer) {
      return { manufacturerIn: [manufacturer] }
    },
  },
}
</script>

<style lang="scss" scoped>
  @import './styles/index';
</style>