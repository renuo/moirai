import { Controller } from "@hotwired/stimulus"

export default class MoiraiTranslationController extends Controller {
  static values = {
    key: String,
    locale: String
  }

  static targets = ["codeWrapper", "textWrapper"]

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
    this.#activateCodeWrapper()
  }
  
  blur(event) {
    this.#deactivateCodeWrapper()
  }

  #activateCodeWrapper() {
    this.active = true
    swapElements(this.textWrapperTarget, this.codeWrapperTarget)
  }

  #deactivateCodeWrapper() {
    this.active = false
    swapElements(this.codeWrapperTarget, this.textWrapperTarget)
  }

  #swapElements(source, destination) {
    source.style.display = 'none'
    destination.style.display = 'block'

    destination.focus()
    destination.innerHTML = source.innerHTML
    source.innerHTML = ''
  }
}
