import { Controller } from "@hotwired/stimulus"

export default class MoiraiTranslationController extends Controller {
  static values = {
    key: String,
    locale: String
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
          value: event.target.innerText
        }
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data?.fallback_translation) {
        event.target.innerText = data.fallback_translation
      }
    })
    .catch(error => {
      console.error('Error:', error);
    });
  }
}
