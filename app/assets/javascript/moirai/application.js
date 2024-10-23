import { Application } from "stimulus";
import { TranslationController } from "moirai";

alert("Hello from the engine!");

const application = Application.start();

application.register("translation", TranslationController);
