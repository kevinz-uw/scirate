class StaffMailer < ActionMailer::Base
  default :from => ENV['MAIL_ADDRESS']

  def report_bug(user, browser, description)
    @user = user
    @browser = browser
    @description = description
    mail(:to => ENV['MAIL_ADDRESS'], :subject => 'Bug Report')
  end
end
