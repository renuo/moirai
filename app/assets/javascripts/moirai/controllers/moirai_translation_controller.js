Stimulus.register(
  "moirai-translation",
  class extends Controller {
    static targets = ["inlineTranslation"]

    connect() {
      console.log(this.inlineTranslationTargets);
    }

    submit(event) {
      console.log(event.target)
      const {filePath, key} = event.target.dataset
      console.log(filePath, key, event.target.dataset)

      const csrfToken = document.querySelector('meta[name="csrf-token"]').content  

      console.log("CSRF TOKEN", csrfToken)

      const formObject = new FormData()
      formObject.append('translation[key]', key)
      formObject.append('translation[file_path]', filePath)
      formObject.append('translation[value]', event.target.innerText)

      console.log({formObject})

      console.log("FOOBAR")


      fetch(`/moirai/translation_files`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': csrfToken
        },
        body: formObject
      }).then(response => {
      }).catch(error => {
      })
    }
  }
);
