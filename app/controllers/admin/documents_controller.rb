class Admin::DocumentsController < ApplicationController
  before_action :authenticate_admin_access

  def destroy
    document  = Document.find(params[:id])
    assistant = document.assistant
    document.destroy
    redirect_to admin_assistant_path(assistant),
                notice: "Deleted '#{document.filename}' and its passages."
  end
end
