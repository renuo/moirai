# frozen_string_literal: true

Moirai::Engine.routes.draw do
  root to: "pages#index"

  resources :translation_files, only: %i[index show]
end
