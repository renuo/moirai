module Moirai
  class TranslationsController < ApplicationController
    def index
      @translations = Translation.order(created_at: :desc).pluck(:locale, :key, :value)
    end
  end
end
