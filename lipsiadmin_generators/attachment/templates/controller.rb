class Backend::AttachmentsController < BackendController

  def index
    params[:limit] ||= 50
    
    @column_store = column_store_for Attachment do |cm|
      cm.add :attacher_type
      cm.add :attached_file_name
      cm.add :attached_content_type
      cm.add :attached_file_size
      cm.add :position
      cm.add :created_at, :renderer => :datetime 
      cm.add :updated_at, :renderer => :datetime 
    end
    
    respond_to do |format|
      format.js 
      format.json do
        render :json => @column_store.store_data(params)
      end
    end
  end

  
  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(params[:attachment])
    if @attachment.save
      redirect_parent_to(:action => "edit", :id => @attachment)
    else
      render_to_parent(:action => "new")
    end
  end

  def edit
    @attachment = Attachment.find(params[:id])
  end

  def update
    @attachment = Attachment.find(params[:id])    
    if @attachment.update_attributes(params[:attachment])
      redirect_parent_to(:action => "edit", :id => @attachment)
    else
      render_to_parent(:action => "edit")
    end 
  end
  
  def order
    # We Need to search the correct params
    ordering = params.find { |k,v| k.to_s =~ /-order$/ }[1]
    ordering.each_with_index do |id, index|
      Attachment.find(id).update_attributes(:position => index)
    end
    render :text => I18n.t("backend.texts.order_updated", :default => "Order Updated!")
  rescue
    render :text => "Params for ordering not found, call it some-order"
  end
  
  # Add in your model before_destroy and if the callback returns false, 
  # all the later callbacks and the associated action are cancelled.
  def destroy
    if Attachment.find(params[:id]).destroy
      render :json => { :success => true } 
    else
      render :json => { :success => false, :msg => I18n.t("backend.general.cantDelete") }
    end
  end
end