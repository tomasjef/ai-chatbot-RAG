class Admin::DocumentsController < ApplicationController
  http_basic_authenticate_with name: "admin", password: "halo-demo"

  def destroy
    document  = Document.find(params[:id])
    assistant = document.assistant
    document.destroy
    redirect_to admin_assistant_path(assistant),
                notice: "Deleted '#{document.filename}' and its passages."
  end
end
