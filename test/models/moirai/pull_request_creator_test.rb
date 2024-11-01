# frozen_string_literal: true

require "test_helper"

module Moirai
  class PullRequestCreatorTest < ActiveSupport::TestCase
    setup do
      @pull_request_creator = PullRequestCreator.new
    end

    test "it's available when Octokit is also available" do
      assert PullRequestCreator.available?
    end

    test "it has a github_repo_name" do
      assert @pull_request_creator.github_repo_name
    end

    test "it has a github_access_token" do
      assert @pull_request_creator.github_access_token
    end

    test "it has a github_client" do
      assert @pull_request_creator.github_client
    end

    test "it creates a new pull request with the required changes" do
      changes = [Change.new("README.md", "New content for README.md"),
        Change.new("config/locales/moirai.de.yml", "New file added")]

      @pull_request_creator.create_pull_request(changes)

      repository = @pull_request_creator.github_repository
      default_branch = repository.default_branch
      assert_equal "main", default_branch
      assert @pull_request_creator.moirai_branch_exists?
      pr = @pull_request_creator.existing_open_pull_request
      assert pr

      @pull_request_creator.cleanup

      refute @pull_request_creator.existing_open_pull_request
    end
  end
end
