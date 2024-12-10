# frozen_string_literal: true

Rails.application.routes.draw do
  mount Moirai::Engine => Moirai.configuration.root_path, :as => "moirai"

  root to: "home#index"
end
