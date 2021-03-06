import 'stylesheets/admin'
import Vue from 'vue'
import App from 'admin/App'
import ApiClient from 'admin/lib/ApiClient'
import Subscriptions from 'frontend/lib/Subscriptions'
import VTooltip from 'v-tooltip'
import 'frontend/lib/LazyLoad'
import 'frontend/lib/Sentry'
import 'frontend/lib/Bootstrap'
import router from 'admin/lib/Router'
import Comlink from 'frontend/lib/Comlink'
import I18nPlugin from 'frontend/lib/I18n'
import Noty from 'frontend/lib/Noty'

Vue.use(Subscriptions)
Vue.use(ApiClient)
Vue.use(Comlink)
Vue.use(I18nPlugin)
Vue.use(Noty)

Vue.filter('formatSize', size => {
  if (size > 1024 * 1024 * 1024 * 1024) {
    return `${(size / 1024 / 1024 / 1024 / 1024).toFixed(2)} TB`
  }
  if (size > 1024 * 1024 * 1024) {
    return `${(size / 1024 / 1024 / 1024).toFixed(2)} GB`
  }
  if (size > 1024 * 1024) {
    return `${(size / 1024 / 1024).toFixed(2)} MB`
  }
  if (size > 1024) {
    return `${(size / 1024).toFixed(2)} KB`
  }
  return `${size.toString()} B`
})

if (process.env.NODE_ENV !== 'production') {
  Vue.config.devtools = true
} else {
  Vue.config.productionTip = false
}

VTooltip.enabled = window.innerWidth > 768
Vue.use(VTooltip)

console.info(`API Endpoint: ${window.API_ENDPOINT}`)

document.addEventListener('DOMContentLoaded', () => {
  if ('serviceWorker' in navigator) {
    // eslint-disable-next-line compat/compat
    navigator.serviceWorker.getRegistrations().then(registrations => {
      registrations.forEach(registration => registration.unregister())
    })
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: '#app',
    router,
    render: h => h(App),
  })
})
