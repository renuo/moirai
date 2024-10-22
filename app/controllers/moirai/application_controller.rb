# frozen_string_literal: true

module Moirai
  class ApplicationController < ActionController::Base
    before_action :authenticate, if: :basic_auth_present?
    def authenticate
      if basic_auth_present?
        authenticate_or_request_with_http_basic do |name, password|
          name == ENV["MOIRAI_BASICAUTH_NAME"] && password == ENV["MOIRAI_BASICAUTH_PASSWORD"]
        end
      end
    end
  end

  private

  def basic_auth_present?
    ENV["MOIRAI_BASICAUTH_NAME"].present? && ENV["MOIRAI_BASICAUTH_PASSWORD"].present?
  end
end
