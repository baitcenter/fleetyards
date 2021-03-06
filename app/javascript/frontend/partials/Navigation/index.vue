<template>
  <nav
    ref="navigation"
    :class="{
      'visible': !navCollapsed,
      'nav-slim': slim,
    }"
    role="navigation"
  >
    <button
      v-if="mobile"
      :class="{
        collapsed: navCollapsed,
      }"
      class="nav-toggle"
      type="button"
      aria-label="Toggle Navigation"
      @click.stop.prevent="toggle"
    >
      <span class="sr-only">
        {{ $t('labels.toggleNavigation') }}
      </span>
      <span class="icon-bar top-bar" />
      <span class="icon-bar middle-bar" />
      <span class="icon-bar bottom-bar" />
    </button>
    <div
      v-if="nodeEnv && !mobile"
      :class="{
        'spacing-right': this.$route.name === 'home',
      }"
      class="environment-label"
    >
      <span :class="environmentLabelClasses">
        <i class="far fa-info-circle" />
        {{ nodeEnv }}
      </span>
      <span
        class="git-revision"
        :class="environmentLabelClasses"
        @click="copyGitRevision"
      >
        <i class="far fa-fingerprint" />
        {{ gitRevision }}
      </span>
    </div>
    <QuickSearch v-if="$route.meta.quickSearch" />
    <div
      :class="{
        'nav-container-slim': slim,
      }"
      class="nav-container"
    >
      <div class="nav-container-inner">
        <ul>
          <UserNav v-if="isAuthenticated" />
          <NavItem
            v-else
            key="user-menu-guest"
            :to="{ name: 'login' }"
            :label="$t('nav.login')"
            icon="fad fa-sign-in"
          />
          <NavItem
            :to="{ name: 'home' }"
            :label="$t('nav.home')"
            :icon="isFleetRoute ? 'fal fa-chevron-left' : 'fad fa-home-alt'"
            exact
          />
          <FleetNav v-if="isFleetRoute" />
          <template v-else>
            <NavItem
              v-if="isAuthenticated || !hangarPreview"
              :to="{ name: 'hangar' }"
              :label="$t('nav.hangar')"
              icon="fad fa-bookmark"
            />
            <NavItem
              v-else
              :to="{ name: 'hangar-preview' }"
              :label="$t('nav.hangar')"
              icon="fal fa-bookmark"
            />
            <NavItem
              :to="{ name: 'models' }"
              :label="$t('nav.models')"
              icon="fad fa-starship"
            />
            <StationsNav />
            <FleetsNav />
            <NavItem
              :to="{ name: 'images' }"
              :label="$t('nav.images')"
              icon="fad fa-images"
            />
            <NavItem
              :to="{
                name: 'trade-routes',
                query: {
                  q: this.$store.state.filters['trade-routes'],
                },
              }"
              :label="$t('nav.tradeRoutes')"
              icon="fad fa-pallet-alt"
            />
            <RoadmapNav />
            <NavItem
              :to="{ name: 'stats' }"
              :label="$t('nav.stats')"
              icon="fad fa-chart-bar"
            />
          </template>
        </ul>
        <NavFooter />
      </div>
    </div>
  </nav>
</template>

<script>
import { mapGetters } from 'vuex'
import QuickSearch from 'frontend/partials/Navigation/QuickSearch'
import NavItem from 'frontend/partials/Navigation/NavItem'
import UserNav from 'frontend/partials/Navigation/UserNav'
import FleetNav from 'frontend/partials/Navigation/FleetNav'
import FleetsNav from 'frontend/partials/Navigation/FleetsNav'
import StationsNav from 'frontend/partials/Navigation/StationsNav'
import RoadmapNav from 'frontend/partials/Navigation/RoadmapNav'
import NavFooter from 'frontend/partials/Navigation/NavFooter'
import NavigationMixin from 'frontend/mixins/Navigation'

export default {
  name: 'Navigation',

  components: {
    QuickSearch,
    NavItem,
    UserNav,
    FleetNav,
    FleetsNav,
    StationsNav,
    RoadmapNav,
    NavFooter,
  },

  mixins: [NavigationMixin],

  data() {
    return {
      searchQuery: null,
    }
  },

  computed: {
    ...mapGetters('app', ['navCollapsed', 'isUpdateAvailable', 'gitRevision']),

    ...mapGetters('hangar', {
      hangarPreview: 'preview',
    }),

    isFleetRoute() {
      return [
        'fleet',
        'fleet-members',
        'fleet-settings',
        'fleet-settings-fleet',
        'fleet-settings-membership',
      ].includes(this.$route.name)
    },

    environmentLabelClasses() {
      const cssClasses = ['pill']

      if (window.NODE_ENV === 'staging') {
        cssClasses.push('pill-warning')
      } else if (window.NODE_ENV === 'production') {
        cssClasses.push('pill-danger')
      }

      return cssClasses
    },

    nodeEnv() {
      if (window.NODE_ENV === 'production') {
        return null
      }

      return (window.NODE_ENV || '').toUpperCase()
    },
  },

  watch: {
    $route() {
      this.close()
    },
  },

  created() {
    document.addEventListener('click', this.documentClick)
  },

  destroyed() {
    document.removeEventListener('click', this.documentClick)
  },

  beforeDestroy() {
    this.close()
  },

  methods: {
    documentClick(event) {
      const element = this.$refs.navigation
      const { target } = event

      if (element !== target && !element.contains(target)) {
        this.close()
      }
    },

    toggle() {
      this.$store.commit('app/toggleNav')
    },

    open() {
      this.$store.commit('app/openNav')
    },

    close() {
      this.$store.commit('app/closeNav')
    },

    reload() {
      this.close()

      window.location.reload(true)
    },

    copyGitRevision() {
      this.$copyText(this.gitRevision).then(
        () => {
          this.$success({
            text: this.$t('messages.copyGitRevision.success'),
          })
        },
        () => {
          this.$alert({
            text: this.$t('messages.copyGitRevision.failure'),
          })
        },
      )
    },
  },
}
</script>

<style lang="scss">
@import 'index';
</style>
