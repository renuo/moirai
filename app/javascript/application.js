import { Application } from "stimulus";
import { TranslationController } from "moirai";

const application = Application.start();

application.register("translation", TranslationController);
