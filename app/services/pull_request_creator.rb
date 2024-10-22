require 'octokit' unless defined? Octokit

class PullRequestCreator
  BRANCH_NAME = 'moirai-translations'

  def initialize
    @github_repo_name = ENV['GITHUB_REPO_NAME']
    @github_access_token = ENV['GITHUB_ACCESS_TOKEN']
    @client = Octokit::Client.new(
      access_token: @github_access_token
    )
  end

  def create_pull_request(translations_array)
    repo = @client.repo(@github_repo_name)
    default_branch = repo.default_branch

    if branch_exists?
      puts "Branch #{BRANCH_NAME} already exists - the branch will be updated with the new changes"
    else
      puts "Branch #{BRANCH_NAME} does not exist - creating branch"
      default_branch_ref = @client.ref(@github_repo_name, "heads/#{default_branch}")
      latest_commit_sha = default_branch_ref.object.sha

      @client.create_ref(@github_repo_name, "heads/#{BRANCH_NAME}", latest_commit_sha)
    end

    translations_array.each do |translation_hash|
      update_file(translation_hash[:path], translation_hash[:content])
    end

    unless pull_request_exists?
      pull_request = @client.create_pull_request(
        @github_repo_name,
        default_branch,
        BRANCH_NAME,
        "Adding new content by Moirai",
        "BODY - This is a pull request created by Moirai"
      )

      puts "Pull request created: #{pull_request.html_url}"
    end
  end

  def branch_exists?
    begin
      @client.ref(@github_repo_name, "heads/#{BRANCH_NAME}")
      true
    rescue Octokit::NotFound
      false
    end
  end

  def update_file(path, content)
    # TODO: check what happens if branch exists

    begin
      file = @client.contents(@github_repo_name, path: path, ref: BRANCH_NAME)
      file_sha = file.sha

      @client.update_contents(
        @github_repo_name,
        path,
        "Updating translations for #{path} by Moirai",
        file_sha,
        content,
        branch: BRANCH_NAME
      )
    rescue Octokit::NotFound
      @client.create_contents(
        @github_repo_name,
        path,
        "Creating translations for #{path} by Moirai",
        content,
        branch: BRANCH_NAME
      )
    end

  end

  def pull_request_exists?
    @client.pull_requests(@github_repo_name).any? do |pull_request|
      pull_request.head.ref == BRANCH_NAME
    end
  end
end
