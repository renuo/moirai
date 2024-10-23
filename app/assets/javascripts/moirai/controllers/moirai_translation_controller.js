Stimulus.register(
  "moirai-translation",
  class extends Controller {
    click(event) {
      event.preventDefault()
    }

    submit(event) {
      const {filePath, key} = event.target.dataset

      const csrfToken = document.querySelector('meta[name="csrf-token"]').content  

      const formObject = new FormData()
      formObject.append('translation[key]', key)
      formObject.append('translation[file_path]', filePath)
      formObject.append('translation[value]', event.target.innerText)

      fetch(`/moirai/translation_files`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': csrfToken
        },
        body: formObject
      })
    }
  }
);
