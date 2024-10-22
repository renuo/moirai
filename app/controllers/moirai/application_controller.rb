# frozen_string_literal: true

module Moirai
  class ApplicationController < ActionController::Base
    before_action :authenticate

    def authenticate
      strategy = Moirai.authentication_strategy.new
      if strategy.authenticate(request)
        true
      else
        head :unauthorized
        false
      end
    end
  end
end
