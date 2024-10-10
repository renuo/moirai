# frozen_string_literal: true

module Moirai
  class PagesController < ApplicationController
    def index
      render plain: "Hello World"
    end
  end
end
