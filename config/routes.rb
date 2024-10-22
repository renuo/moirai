# frozen_string_literal: true

Moirai::Engine.routes.draw do
  root to: "pages#index"

  resources :translation_files, only: %i[index show], as: "moirai_translation_files"
  post "/translation_files/:id", to: "translation_files#create_or_update", as: "moirai_create_or_update_translation"
end
