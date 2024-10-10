# frozen_string_literal: true

require "test_helper"

class TestPagesController < ActionDispatch::IntegrationTest
  def test_index
    get "/moirai"

    assert_response :success
    assert_includes @response.body, "Hello World"
  end
end
