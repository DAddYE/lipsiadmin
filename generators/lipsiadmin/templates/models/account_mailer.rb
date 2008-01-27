class AccountMailer < ActionMailer::Base
  def signup_notification(account)
    setup_email(account)
    @subject    += 'Your account'
    @body[:url]  = "http://#{AppConfig.host_addr}/admin/accounts/activate/#{account.activation_code}"  
  end
  
  def activation(account)
    setup_email(account)
    @subject    += 'Account activated!'
    @body[:url]  = "http://#{AppConfig.host_addr}/"
  end
  
  protected
    def setup_email(account)
      @recipients  = "#{account.email}"
      @from        = AppConfig.email_from
      @subject     = "[#{AppConfig.email_object}] "
      @sent_on     = Time.now
      @body[:account] = account
    end
end
