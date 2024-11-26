require "test_helper"

class ApplicationMailerTest < ActiveSupport::TestCase
  test "moirai is used also in emails" do
    mailer = ApplicationMailer.test
    assert_match(/Welcome/, mailer.body.to_s)
    refute_match(/Changed/, mailer.body.to_s)

    Moirai::Translation.create(locale: "en", key: "email.welcome", value: "Changed")

    mailer = ApplicationMailer.test
    refute_match(/Welcome/, mailer.body.to_s)
    assert_match(/Changed/, mailer.body.to_s)
  end
end
