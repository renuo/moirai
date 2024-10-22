# frozen_string_literal: true

Rails.application.routes.draw do
  mount Moirai::Engine => "/moirai"

  root to: "home#index"
end
