class Moirai::PullRequestCreator
  BRANCH_NAME = "moirai-translations"

  def self.available?
    !!defined?(Octokit)
  end

  attr_reader :github_repo_name, :github_access_token, :github_client, :github_repository

  def initialize
    @github_repo_name = ENV["MOIRAI_GITHUB_REPO_NAME"] || Rails.application.credentials.dig(:moirai, :github_repo_name)
    @github_access_token = ENV["MOIRAI_GITHUB_ACCESS_TOKEN"] || Rails.application.credentials.dig(:moirai, :github_access_token)
    @github_client = Octokit::Client.new(access_token: github_access_token)
    @github_repository = github_client.repo(github_repo_name)
  end

  def create_pull_request(translations_array)
    default_branch = github_repository.default_branch

    if moirai_branch_exists?
      puts "Branch #{BRANCH_NAME} already exists - the branch will be updated with the new changes"
    else
      puts "Branch #{BRANCH_NAME} does not exist - creating branch"
      default_branch_ref = @github_client.ref(@github_repo_name, "heads/#{default_branch}")
      latest_commit_sha = default_branch_ref.object.sha

      @github_client.create_ref(@github_repo_name, "heads/#{BRANCH_NAME}", latest_commit_sha)
    end

    translations_array.each do |translation_hash|
      converted_file_path = if translation_hash[:file_path].start_with?("./")
        translation_hash[:file_path]
      else
        "./#{translation_hash[:file_path]}"
      end
      update_file(converted_file_path, translation_hash[:content])
    end

    unless open_pull_request.present?
      pull_request = @github_client.create_pull_request(
        @github_repo_name,
        default_branch,
        BRANCH_NAME,
        "Adding new content by Moirai",
        "BODY - This is a pull request created by Moirai"
      )

      puts "Pull request created: #{pull_request.html_url}"
    end
  end

  def moirai_branch_exists?
    @github_client.ref(@github_repo_name, "heads/#{BRANCH_NAME}")
    true
  rescue Octokit::NotFound
    false
  end

  def open_pull_request
    @github_client.pull_requests(@github_repo_name).find do |pull_request|
      (pull_request.head.ref == BRANCH_NAME) && (pull_request.state == "open")
    end
  end

  private

  def update_file(path, content)
    # TODO: check what happens if branch exists
    file = @github_client.contents(@github_repo_name, path: path, ref: BRANCH_NAME)
    file_sha = file.sha

    @github_client.update_contents(
      @github_repo_name,
      path,
      "Updating translations for #{path} by Moirai",
      file_sha,
      content,
      branch: BRANCH_NAME
    )
  rescue Octokit::NotFound
    @github_client.create_contents(
      @github_repo_name,
      path,
      "Creating translations for #{path} by Moirai",
      content,
      branch: BRANCH_NAME
    )
  end
end
