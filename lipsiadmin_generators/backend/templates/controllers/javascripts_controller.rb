class JavascriptsController < ApplicationController
  helper Lipsiadmin::View::Helpers::BackendHelper
  
  def backend
    respond_to do |format|
      format.html { render :text => "Resource is not available, regardless of authorization. Often the result of bad file or directory permissions on the server. ", :status => '403 Forbidden' }
      format.js { @panels = [] }
    end
  end

  def locale
    respond_to do |format|
      format.html { render :text => "Resource is not available, regardless of authorization. Often the result of bad file or directory permissions on the server. ", :status => '403 Forbidden' }
      format.js
    end
  end
end