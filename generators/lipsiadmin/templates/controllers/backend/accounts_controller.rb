class Backend::AccountsController < BackendController
  def list
    respond_to do |format|
      format.html
      format.json do 
        accounts = Account.find(:all)
        return_data = Hash.new 
        return_data[:accounts] = accounts.collect { |u| { :id => u.id,
                                                          :email => u.email,
                                                          :active => u.active?, 
                                                          :admin => u.admin,
                                                          :created_at => u.created_at } }
        render :json => return_data
      end
    end
  end
  
  def create
    @account = Account.new(params[:account])
    @account.admin = true
    @account.save!
    redirect_to list_backend_accounts_path
  rescue ActiveRecord::RecordInvalid
    render :action => :new
  end
  
  def new
    @account = Account.new
  end
  
  def edit
    @account = Account.find(params[:id])
  end
  
  def update
    @account = Account.find(params[:id])
    @account.update_attributes!(params[:account])
    redirect_to list_backend_accounts_path
  rescue ActiveRecord::RecordInvalid
    render :action => :edit
  end
  
  def destroy
    if Account.find(params[:id]).destroy
      render :json => { :success => true } 
    else
      render :json => { :success => false, :msg => "You cannot delete this record." }
    end  
  end

  def activate
    self.current_account = params[:activation_code].blank? ? :false : Account.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_account.active?
      current_account.activate
      flash[:notice] = "Activation Completed!"
    end
    redirect_to new_backend_session_path
  end
end