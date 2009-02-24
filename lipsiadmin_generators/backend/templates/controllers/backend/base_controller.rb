class Backend::BaseController < BackendController
  def support_request
    Notifier.deliver_support_request(current_account, params[:message])
    render :json => { :success => true }
  rescue Exception => e
    render :json => { :success => false, :msg => e.message }
  end
end