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
    get translation_file_url("config/locales/en.yml")
    assert_response :success

    assert_select "h1", "Update translations"
    assert_select "code", "./config/locales/en.yml"
  end

  test "#show does not exist" do
    get "/moirai/translation_files/does_not_exist"
    assert_response :not_found
  end

  # existing file with existing translation, with no change record present
  test "#create_or_update with new translation record" do
    translation_count_before = Moirai::Translation.count
    post "/moirai/translation_files", params: { translation: { key: "locales.german", locale: "en", value: "New Translation" } }

    assert_response :redirect
    assert_redirected_to translation_file_url("config/locales/en.yml")
    assert_equal "Translation locales.german was successfully created.", flash[:notice]
    assert_equal translation_count_before + 1, Moirai::Translation.count
  end
end

private

def translation_file_url(local_path)
  absolute_path = Rails.root.join(local_path).to_s
  "/moirai/translation_files/#{Digest::SHA256.hexdigest(absolute_path)}"
end
