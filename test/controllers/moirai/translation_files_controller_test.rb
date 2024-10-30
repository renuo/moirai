require "test_helper"

class TranslationFilesController < ActionDispatch::IntegrationTest
  setup do
    @translation = Moirai::Translation.create(key: "locales.german", locale: "de", value: "Neudeutsch")
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

  # create tests

  test "create with valid params" do
    translation_count_before = Moirai::Translation.count
    post "/moirai/translation_files", params: { translation: { key: "locales.german", locale: "en", value: "New Translation" } }

    assert_response :redirect
    assert_redirected_to translation_file_url("config/locales/en.yml")
    assert_equal "Translation locales.german was successfully created.", flash[:notice]
    assert_equal Moirai::Translation.last.key, "locales.german"
    assert_equal Moirai::Translation.last.value, "New Translation"
  end

  test "create with same value" do
    translation_count_before = Moirai::Translation.count

    post "/moirai/translation_files", params: { translation: { key: "locales.german", locale: "en", value: "German" } }

    assert_response :redirect
    assert_redirected_to translation_file_url("config/locales/en.yml")
    assert_equal "Translation locales.german already exists.", flash[:alert]
    assert_equal translation_count_before, Moirai::Translation.count
  end

  test "create with invalid params" do
    translation_count_before = Moirai::Translation.count

    post "/moirai/translation_files", params: { translation: { key: "", locale: "", value: "" } }

    assert_response :unprocessable_entity
    assert_equal "Key can't be blank, Locale can't be blank", flash[:alert]
    assert_equal translation_count_before, Moirai::Translation.count
  end

  # update tests

  test "update with blank value" do
    count_before = Moirai::Translation.count
    post "/moirai/translation_files", params: { translation: { key: "locales.german", locale: "de", value: "" } }

    assert_response :redirect
    assert_redirected_to translation_file_url("config/locales/de.yml")
    assert_equal "Translation locales.german was successfully deleted.", flash[:notice]
    assert_equal count_before - 1, Moirai::Translation.count
  end

  test "update with non blank new value" do
    post "/moirai/translation_files", params: { translation: { key: "locales.german", locale: "de", value: "Hochdeutsch" } }

    assert_response :redirect
    assert_redirected_to translation_file_url("config/locales/de.yml")
    assert_equal "Translation locales.german was successfully updated.", flash[:notice]
    assert_equal Moirai::Translation.last.key, "locales.german"
    assert_equal Moirai::Translation.last.value, "Hochdeutsch"
  end

  test "update with value from file" do
    count_before = Moirai::Translation.count
    post "/moirai/translation_files", params: { translation: { key: "locales.german", locale: "de", value: "Deutsch" } }

    assert_response :redirect
    assert_redirected_to translation_file_url("config/locales/de.yml")
    assert_equal "Translation locales.german was successfully deleted.", flash[:notice]
    assert_equal count_before - 1, Moirai::Translation.count
  end
end

private

def translation_file_url(local_path)
  absolute_path = Rails.root.join(local_path).to_s
  "/moirai/translation_files/#{Digest::SHA256.hexdigest(absolute_path)}"
end
