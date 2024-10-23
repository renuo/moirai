Stimulus.register(
  "hello",
  class extends Controller {
    connect() {
      console.log("hello world");
    }
  }
);
