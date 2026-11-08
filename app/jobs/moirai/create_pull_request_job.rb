module Moirai
  class CreatePullRequestJob < ApplicationJob
    FREQUENCY = 5.minutes

    def perform
      last_update = Moirai::Translation.order(updated_at: :desc).first&.updated_at

      return if last_update && last_update.after?(FREQUENCY.ago)

      Moirai::PullRequestCreator.new.create_pull_request
    end
  end
end
