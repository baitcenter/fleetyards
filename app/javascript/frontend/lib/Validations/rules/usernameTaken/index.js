import { post } from 'frontend/lib/ApiClient'
import { I18n } from 'frontend/lib/I18n'

export default {
  message() {
    return I18n.t('messages.error.usernameTaken')
  },
  validate(value) {
    return post('users/check-username', { username: value }, true)
      .then(({ data }) => ({
        valid: !data.usernameTaken,
      }))
      .catch(() => ({ valid: true }))
  },
}
