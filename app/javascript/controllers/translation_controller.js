import { Controller } from "stimulus";

export default class extends Controller {
  connect() {
    console.log("Stimulus controller in the engine is connected!");
  }
}
