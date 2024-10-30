require "test_helper"

class TranslationFilesController < ActionDispatch::IntegrationTest
  setup do
    @translation = Moirai::Translation.create(key: "test_key", locale: "en", value: "test_value")
  end

  test "#index" do
    get "/moirai"

    assert_response :success

    assert_select "h1", "Translation files"
    assert_includes response.body, "de.yml"
    assert_includes response.body, "en.yml"
    assert_includes response.body, "it.yml"
  end

  test "#show exists" do
    get "/moirai/translation_files/#{Digest::SHA256.hexdigest(Rails.root.join("config/locales/en.yml").to_s)}"
    assert_response :success

    assert_select "h1", "Update translations"
    assert_select "code", "./config/locales/en.yml"
  end

  test "#show does not exist" do
    get "/moirai/translation_files/does_not_exist"
    assert_response :not_found
  end
end
