class Backend::<%= controller_class_name %>Controller < BackendController

<% for action in unscaffolded_actions -%>
  def <%= action %><%= suffix %>
  end

<% end -%>
  def index
    respond_to do |format|
      format.html
      format.json do
        <%= plural_name %> = <%= model_name %>.find(:all)
        return_data = Hash.new()      
        return_data[:<%= plural_name %>] = <%= plural_name %>.collect{|u| { :id => u.id, <%= model_instance.class.content_columns.collect{ |column| "
                                                        :#{column.name} => u.#{column.name}" }.join(",") %> } } 
        render :json => return_data
      end
    end
  end

  def new<%= suffix %>
    @<%= singular_name %> = <%= model_name %>.new
  end

  def create<%= suffix %>
    @<%= singular_name %> = <%= model_name %>.new(params[:<%= singular_name %>])
    if @<%= singular_name %>.save
      redirect_to :action => :index
    else
      render :action => :new
    end
  end

  def edit<%= suffix %>
    @<%= singular_name %> = <%= model_name %>.find(params[:id])
  end

  def update
    @<%= singular_name %> = <%= model_name %>.find(params[:id])    
    if @<%= singular_name %>.update_attributes(params[:<%= singular_name %>])
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end
  
  # Add in your model before_destroy and if the callback returns false, 
  # all the later callbacks and the associated action are cancelled.
  def destroy<%= suffix %>
    if <%= model_name %>.find(params[:id]).destroy
      render :json => { :success => true } 
    else
      render :json => { :success => false, :msg => "You cannot delete this record." }
    end
  end
<% for image in images -%>  
  def destroy_<%= image.downcase %>
    <%= model_name %>.find(params[:id]).<%= image.downcase %>.destroy
    redirect_to :action => :edit
  end
<% end -%>
<% for file in files -%>  
  def destroy_<%= file.downcase %>
    <%= model_name %>.find(params[:id]).<%= file.downcase %>.destroy
    redirect_to :action => :edit, :id => params[:id]
  end
<% end -%>
end