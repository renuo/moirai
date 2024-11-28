# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  def test
    mail(to: "moirai@renuo.ch", cc: "alessandro.rodi@renuo.ch", subject: "this is a test")
  end
end
