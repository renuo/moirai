require "test_helper"

class TranslationFilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @translation = Moirai::Translation.create(key: "locales.german", locale: "de", value: "Neudeutsch")
  end

  # Index action tests
  test "index displays translation files" do
    get index_url

    assert_response :success
    assert_select "h1", "Translation files"
    assert_includes response.body, "de.yml"
    assert_includes response.body, "en.yml"
    assert_includes response.body, "it.yml"
  end

  # Show action tests
  test "show existing translation file" do
    get translation_file_url("config/locales/en.yml")
    assert_response :success

    assert_select "h1", "Update translations"
    assert_select "code", "./config/locales/en.yml"
  end

  test "show non-existing translation file" do
    get translation_file_url("does_not_exist.yml")
    assert_response :not_found
  end

  # Create action tests
  test "create translation with valid params" do
    translation_count_before = Moirai::Translation.count
    post translation_files_url, params: {translation: {key: "locales.german", locale: "en", value: "New Translation"}}

    assert_response :redirect
    assert_redirected_to translation_file_url("config/locales/en.yml")
    assert_equal "Translation locales.german was successfully created.", flash[:notice]
    assert_equal Moirai::Translation.last.key, "locales.german"
    assert_equal Moirai::Translation.last.value, "New Translation"
    assert_equal translation_count_before + 1, Moirai::Translation.count
  end

  test "create translation with existing value" do
    translation_count_before = Moirai::Translation.count

    post translation_files_url, params: {translation: {key: "locales.german", locale: "en", value: "German"}}

    assert_response :unprocessable_entity
    assert_equal "Translation locales.german already exists.", flash[:alert]
    assert_equal translation_count_before, Moirai::Translation.count
  end

  test "create translation with invalid params" do
    translation_count_before = Moirai::Translation.count

    post translation_files_url, params: {translation: {key: "", locale: "", value: ""}}

    assert_response :unprocessable_entity
    assert_equal "Key can't be blank, Locale can't be blank, Value can't be blank", flash[:alert]
    assert_equal translation_count_before, Moirai::Translation.count
  end

  # Update action tests
  test "update translation with blank value" do
    count_before = Moirai::Translation.count
    post translation_files_url, params: {translation: {key: "locales.german", locale: "de", value: ""}}

    assert_response :redirect
    assert_redirected_to translation_file_url("config/locales/de.yml")
    assert_equal "Translation locales.german was successfully deleted.", flash[:notice]
    assert_equal count_before - 1, Moirai::Translation.count
  end

  test "update translation with non-blank new value" do
    post translation_files_url, params: {translation: {key: "locales.german", locale: "de", value: "Hochdeutsch"}}

    assert_response :redirect
    assert_redirected_to translation_file_url("config/locales/de.yml")
    assert_equal "Translation locales.german was successfully updated.", flash[:notice]
    assert_equal Moirai::Translation.last.key, "locales.german"
    assert_equal Moirai::Translation.last.value, "Hochdeutsch"
  end

  test "update translation with value from file" do
    count_before = Moirai::Translation.count
    post translation_files_url, params: {translation: {key: "locales.german", locale: "de", value: "Deutsch"}}

    assert_response :redirect
    assert_redirected_to translation_file_url("config/locales/de.yml")
    assert_equal "Translation locales.german was successfully deleted.", flash[:notice]
    assert_equal count_before - 1, Moirai::Translation.count
  end

  test "creates a pull request with all the file changes" do
    Moirai::Translation.create!(key: "locales.italian",
      locale: "de",
      value: "Italianese")

    Moirai::Translation.create!(key: "locales.italian",
      locale: "it",
      value: "Italianese")

    post moirai.moirai_open_pr_path

    assert_response :found

    @pull_request_creator = Moirai::PullRequestCreator.new

    pr = @pull_request_creator.existing_open_pull_request

    assert pr
    file = @pull_request_creator.github_client.contents(@pull_request_creator.github_repo_name,
      path: "./config/locales/it.yml",
      ref: @pull_request_creator.branch_name)
    pr_file_content = Base64.decode64(file.content)
    proposed_translations = YAML.load(pr_file_content, symbolize_names: true)
    assert "Italianese", proposed_translations.dig(:it, :locales, :italian)

    @pull_request_creator.cleanup
    refute @pull_request_creator.existing_open_pull_request
  end

  private

  def index_url
    "/moirai"
  end

  def translation_files_url
    "/moirai/translation_files"
  end

  def translation_file_url(local_path)
    absolute_path = Rails.root.join(local_path).to_s
    "/moirai/translation_files/#{Digest::SHA256.hexdigest(absolute_path)}"
  end
end
