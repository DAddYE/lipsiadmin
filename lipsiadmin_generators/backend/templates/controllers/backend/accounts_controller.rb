class Backend::AccountsController < BackendController
  def index
    params[:limit] ||= 50
    @column_store = column_store_for Account do |cm|
      cm.add :name
      cm.add :surname
      cm.add :email
      cm.add :created_at, :renderer => :datetime, :align => :right
      cm.add :updated_at, :renderer => :datetime, :align => :right
    end
    
    respond_to do |format|
      format.js 
      format.json do
        render :json => @column_store.store_data(params)
      end
    end
  end

  def new
    @account = Account.new
  end
  
  def create
    @account = Account.new(params[:account])
    if @account.save
      redirect_parent_to(:action => "edit", :id => @account)
    else
      render_to_parent(:action => "new")
    end
  end
  
  def edit
    @account = Account.find(params[:id])
  end
  
  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account])
      redirect_parent_to(:action => "edit", :id => @account)
    else
      render_to_parent(:action => "edit")
    end 
  end
  
  def destroy
    if Account.find(params[:id]).destroy
      render :json => { :success => true } 
    else
      render :json => { :success => false, :msg => I18n.t("backend.general.cantDelete") }
    end  
  end
end