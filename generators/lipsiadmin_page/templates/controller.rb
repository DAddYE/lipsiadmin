class Backend::<%= controller_class_name %>Controller < BackendController

<% for action in unscaffolded_actions -%>
  def <%= action %><%= suffix %>
  end

<% end -%>
  def list
    respond_to do |format|
      format.html
      format.json do
        <%= plural_name %> = <%= model_name %>.find(:all)
        return_data = Hash.new()      
        return_data[:Total] = <%= plural_name %>.size     
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
<% if options[:with_images] -%>
    @<%= singular_name %>.build_image(params[:image]) unless params[:image][:uploaded_data].blank?
<% end -%>
    if @<%= singular_name %>.save
      redirect_to list_backend_<%= plural_name %>_path
    else
<% if options[:with_images] -%>
      @<%= singular_name %>.image = nil
<% end -%>
      render :action => :new
    end
  end

  def edit<%= suffix %>
    @<%= singular_name %> = <%= model_name %>.find(params[:id])
  end

  def update
    @<%= singular_name %> = <%= model_name %>.find(params[:id])    
<% if options[:with_images] -%>    
    @<%= singular_name %>.image.destroy if @<%= singular_name %>.image && !params[:image][:uploaded_data].blank?
    @<%= singular_name %>.build_image(params[:image]) unless params[:image][:uploaded_data].blank?
<% end -%>    
    if @<%= singular_name %>.update_attributes(params[:<%= singular_name %>])
      redirect_to list_backend_<%= plural_name %>_path
    else
<% if options[:with_images] -%>      
      @<%= singular_name %>.image = nil
<% end -%>
      render :action => :edit
    end
  end

  def destroy<%= suffix %>
    <%= model_name %>.find(params[:id]).destroy
    render :json => { :success => true, :msg => '', :data => {} } 
  end
<% if options[:with_images] -%>  
  def destroy_image
    <%= model_name %>.find(params[:id]).image.destroy
    redirect_to edit_backend_<%= singular_name %>_path(params[:id])
  end
<% end -%>
end