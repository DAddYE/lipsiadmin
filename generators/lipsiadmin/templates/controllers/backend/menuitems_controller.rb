class Backend::MenuitemsController < BackendController

  def list
    respond_to do |format|
      format.html
      format.json do
        menuitems = Menuitem.find(:all)
        return_data = Hash.new()      
        return_data[:menus] = menuitems.collect{|u| { :id => u.id, 
                                                      :name => u.name,
                                                      :url => u.url,
                                                      :menu => u.menu,
                                                      :admin => u.admin,
                                                      :style => u.style,
                                                      :position => u.position,
                                                      :created_at => u.created_at,
                                                      :updated_at => u.updated_at } } 
        render :json => return_data
      end
    end
  end

  def new
    @menuitem = Menuitem.new
  end

  def create
    @menuitem = Menuitem.new(params[:menuitem])
    if @menuitem.save
      redirect_to list_backend_menuitems_path
    else
      render :action => :new
    end
  end

  def edit
    @menuitem = Menuitem.find(params[:id])
  end

  def update
    @menuitem = Menuitem.find(params[:id])    
    
    if @menuitem.update_attributes(params[:menuitem])
      redirect_to list_backend_menuitems_path
    else
      render :action => :edit
    end
  end
  
  # Add in your model before_destroy and if the callback returns false, 
  # all the later callbacks and the associated action are cancelled.
  def destroy
    if Menuitem.find(params[:id]).destroy
      render :json => { :success => true } 
    else
      render :json => { :success => false, :msg => "You cannot delete this record." }
    end
  end
end