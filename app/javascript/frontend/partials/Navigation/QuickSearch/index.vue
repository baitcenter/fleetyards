<template>
  <div class="quick-search-bar">
    <form @submit.prevent="filter">
      <FormInput
        :id="$route.meta.quickSearch || 'quicksearch'"
        v-model="form[$route.meta.quickSearch]"
        :translation-key="`quicksearch.${$route.name}`"
        no-label
        autofocus
        clearable
      />
    </form>
  </div>
</template>

<script>
import Filters from 'frontend/mixins/Filters'
import FormInput from 'frontend/components/Form/FormInput'

export default {
  components: {
    FormInput,
  },

  mixins: [Filters],

  data() {
    const query = this.queryParams()

    query[this.$route.meta.quickSearch] =
      query[this.$route.meta.quickSearch] || null

    return {
      form: query,
    }
  },

  watch: {
    $route() {
      const query = this.queryParams()

      query[this.$route.meta.quickSearch] =
        query[this.$route.meta.quickSearch] || null

      this.form = query
    },
    form: {
      handler() {
        this.filter()
      },
      deep: true,
    },
  },

  methods: {
    queryParams() {
      return JSON.parse(JSON.stringify(this.$route.query.q || {}))
    },
  },
}
</script>
