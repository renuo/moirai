require "test_helper"

class TranslationFilesController < ActionDispatch::IntegrationTest
  setup do
    @translation = Moirai::Translation.create(key: "test_key", locale: "en", value: "test_value")
  end

  test "should get index" do
    get "/moirai"

    assert_response :success

    assert_select "h1", "Translation files"
    assert_includes response.body, "de.yml"
    assert_includes response.body, "en.yml"
    assert_includes response.body, "it.yml"
  end
end
