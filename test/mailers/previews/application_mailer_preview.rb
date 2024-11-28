class ApplicationMailerPreview < ActionMailer::Preview
  def test_email
    ApplicationMailer.test
  end
end
