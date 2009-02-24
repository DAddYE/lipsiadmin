class Notifier < ActionMailer::Base
  def registration(account)
    recipients  account.email
    from        AppConfig.email_from
    subject     "[#{AppConfig.project}] #{I18n.t('backend.emails.registration.object')}"
    body        :account => account, :url => "http://#{AppConfig.host_addr}/backend"
  end
  
  def support_request(account, message)
    from        account.email
    recipients  AppConfig.email_help
    subject     "[#{AppConfig.project}] #{I18n.t('backend.emails.support.object')}"
    body        :message => message
  end
end 