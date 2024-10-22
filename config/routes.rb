# frozen_string_literal: true

Moirai::Engine.routes.draw do
  root to: "pages#index"

  resources :translation_files, only: %i[index show]
  post "/translation_files/:id", to: "translation_files#create_or_update", as: "create_or_update_translation"
end
