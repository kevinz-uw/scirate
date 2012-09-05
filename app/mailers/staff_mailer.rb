class StaffMailer < ActionMailer::Base
  default :from => 'scirate.staff@gmail.com'

  def report_bug(user, browser, description)
    @user = user
    @browser = browser
    @description = description
    mail(:to => 'scirate.staff@gmail.com', :subject => 'Bug Report')
  end
end
