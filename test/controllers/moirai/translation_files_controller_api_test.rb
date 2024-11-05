require "test_helper"

class TranslationFilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @translation = Moirai::Translation.create(key: "locales.german", locale: "de", value: "Neudeutsch")
  end

  # Index action tests
  test "index displays translation files" do
    get index_url, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.any? { |file| file["name"] == "de.yml" }
    assert json_response.any? { |file| file["name"] == "en.yml" }
    assert json_response.any? { |file| file["name"] == "it.yml" }
  end

  # Show action tests
  test "show existing translation file" do
    get translation_file_url("config/locales/en.yml"), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal "en", json_response["locale"]
    assert json_response["translation_keys"].is_a?(Hash)
    assert json_response["translations"].is_a?(Array)
  end

  test "show non-existing translation file" do
    get translation_file_url("does_not_exist.yml"), as: :json
    assert_response :not_found
  end

  # Create action tests
  test "create translation with valid params" do
    translation_count_before = Moirai::Translation.count
    post translation_files_url, params: {translation: {key: "locales.german", locale: "en", value: "New Translation"}}, as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Translation created", json_response["message"]
    assert_equal "locales.german", json_response["translation"]["key"]
    assert_equal "New Translation", json_response["translation"]["value"]
    assert_equal translation_count_before + 1, Moirai::Translation.count
  end

  test "create translation with existing value" do
    translation_count_before = Moirai::Translation.count

    post translation_files_url, params: {translation: {key: "locales.german", locale: "en", value: "German"}}, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Translation already exists"
    assert_equal translation_count_before, Moirai::Translation.count
  end

  test "create translation with invalid params" do
    translation_count_before = Moirai::Translation.count

    post translation_files_url, params: {translation: {key: "", locale: "", value: ""}}, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Key can't be blank"
    assert_includes json_response["errors"], "Locale can't be blank"
    assert_includes json_response["errors"], "Value can't be blank"
    assert_equal translation_count_before, Moirai::Translation.count
  end

  # Update action tests
  test "update translation with blank value" do
    count_before = Moirai::Translation.count
    post translation_files_url, params: {translation: {key: "locales.german", locale: "de", value: ""}}, as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Translation deleted", json_response["message"]
    assert_equal count_before - 1, Moirai::Translation.count
  end

  test "update translation with non-blank new value" do
    post translation_files_url, params: {translation: {key: "locales.german", locale: "de", value: "Hochdeutsch"}}, as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Translation updated", json_response["message"]
    assert_equal "locales.german", json_response["translation"]["key"]
    assert_equal "Hochdeutsch", json_response["translation"]["value"]
  end

  test "update translation with value from file" do
    count_before = Moirai::Translation.count
    post translation_files_url, params: {translation: {key: "locales.german", locale: "de", value: "Deutsch"}}, as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Translation deleted", json_response["message"]
    assert_equal count_before - 1, Moirai::Translation.count
  end

  test "creates a pull request with all the file changes" do
    Moirai::Translation.create!(key: "locales.italian",
      locale: "de",
      value: "Italianese")

    Moirai::Translation.create!(key: "locales.italian",
      locale: "it",
      value: "Italianese")

    post moirai.moirai_open_pr_path, as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Pull Request created", json_response["message"]

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
