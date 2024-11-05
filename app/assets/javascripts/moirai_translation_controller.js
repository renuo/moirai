import { Controller } from "@hotwired/stimulus"

export default class MoiraiTranslationController extends Controller {
  static values = {
    key: String,
    locale: String
  }

  static targets = ["codeWrapper", "nonCodeWrapper"]

  connect() {
    this.active = false
  }

  click(event) {
    event.preventDefault()
  }

  submit(event) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    fetch('/moirai/translation_files', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        translation: {
          key: this.keyValue,
          locale: this.localeValue,
          value: event.target.innerHTML
        }
      })
    });
  }

  hover(event) {
    this.active = true
  }

  #activateCodeWrapper() {
    this.codeWrapperTarget.style.display = 'block'
    this.nonCodeWrapperTarget.style.display = 'none'
    this.codeWrapperTarget.focus()
    this.codeWrapperTarget.innerHTML = this.codeWrapperTarget.innerHTML
  }

  #deactivateCodeWrapper() {
    this.codeWrapperTarget.style.display = 'none'
    this.nonCodeWrapperTarget.style.display = 'block'
    this.nonCodeWrapperTarget.focus()
    this.nonCodeWrapperTarget.innerHTML = this.nonCodeWrapperTarget.innerHTML
  }
}
