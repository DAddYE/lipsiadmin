class Backend::StateSessionsController < BackendController
  
  def index
    render :json => current_account.state_sessions
  end

  def create
    current_account.state_sessions.find_or_create_by_component(params[:id]).update_attribute(:data, params[:data])
    render :nothing => true
  end

  def destroy
    state_session = current_account.state_sessions.find_by_component(params[:id])
    state_session.destroy if state_session
    render :nothing => true
  end
end