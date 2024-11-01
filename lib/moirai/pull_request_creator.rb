class Moirai::PullRequestCreator
  def self.available?
    !!defined?(Octokit)
  end

  BRANCH_PREFIX = "moirai-translations-"

  attr_reader :github_repo_name, :github_access_token, :github_client, :github_repository, :branch_name

  def initialize
    @github_repo_name = ENV["MOIRAI_GITHUB_REPO_NAME"] || Rails.application.credentials.dig(:moirai, :github_repo_name)
    @github_access_token = ENV["MOIRAI_GITHUB_ACCESS_TOKEN"] || Rails.application.credentials.dig(:moirai, :github_access_token)
    @github_client = Octokit::Client.new(access_token: github_access_token)
    @github_repository = github_client.repo(github_repo_name)
  end

  def create_pull_request(translations_array)
    @branch_name = "#{BRANCH_PREFIX}#{Time.current.strftime("%F-%H-%M-%S")}-#{rand(1000..9999)}"
    default_branch = github_repository.default_branch

    if moirai_branch_exists?
      Rails.logger.debug { "Branch #{branch_name} already exists - the branch will be updated with the new changes" }
    else
      Rails.logger.debug { "Branch #{branch_name} does not exist - creating branch" }
      default_branch_ref = @github_client.ref(@github_repo_name, "heads/#{default_branch}")
      latest_commit_sha = default_branch_ref.object.sha

      @github_client.create_ref(@github_repo_name, "heads/#{branch_name}", latest_commit_sha)
    end

    translations_array.each do |translation_hash|
      converted_file_path = if translation_hash[:file_path].to_s.start_with?("./")
        translation_hash[:file_path]
      else
        "./#{translation_hash[:file_path]}"
      end
      update_file(converted_file_path, translation_hash[:content])
    end

    unless existing_open_pull_request.present?
      pull_request = @github_client.create_pull_request(
        @github_repo_name,
        default_branch,
        branch_name,
        "Adding new content by Moirai",
        "BODY - This is a pull request created by Moirai"
      )

      puts "Pull request created: #{pull_request.html_url}"
    end
  end

  def moirai_branch_exists?
    @github_client.ref(@github_repo_name, "heads/#{branch_name}")
    true
  rescue Octokit::NotFound
    false
  end

  def existing_open_pull_request
    @github_client.pull_requests(@github_repo_name).find do |pull_request|
      pull_request.head.ref.start_with?(BRANCH_PREFIX) && (pull_request.state == "open")
    end
  end

  def cleanup
    pr = existing_open_pull_request
    @github_client.close_pull_request(@github_repo_name, pr.number)
    @github_client.delete_branch(@github_repo_name, pr.head.ref)
  end

  private

  def update_file(path, content)
    # TODO: check what happens if branch exists
    file = @github_client.contents(@github_repo_name, path: path, ref: branch_name)
    file_sha = file.sha

    @github_client.update_contents(
      @github_repo_name,
      path,
      "Updating translations for #{path} by Moirai",
      file_sha,
      content,
      branch: branch_name
    )
  rescue Octokit::NotFound
    @github_client.create_contents(
      @github_repo_name,
      path,
      "Creating translations for #{path} by Moirai",
      content,
      branch: branch_name
    )
  end
end
