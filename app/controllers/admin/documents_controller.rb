class Admin::DocumentsController < ApplicationController
  before_action :authenticate_admin_access

  def destroy
    document = Document.find(params[:id])
    document.destroy
    redirect_to admin_root_path,
                notice: "Deleted '#{document.filename}' and its passages."
  end
end
