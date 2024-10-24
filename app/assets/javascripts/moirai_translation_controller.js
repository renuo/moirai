import { Controller } from "@hotwired/stimulus"

export default class MoiraiTranslationController extends Controller {
  click(event) {
    event.preventDefault()
  }

  submit(event) {
    const {filePath, key} = event.target.dataset

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    fetch(`/moirai/translation_files`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        translation: {
          key: key,
          file_path: filePath,
          value: event.target.innerText
        }
      })
    });
  }
}
