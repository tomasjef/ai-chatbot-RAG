class DocumentsController < ApplicationController
  before_action :authenticate_demo_access

  def show
    document = Document.find(params[:id])
    return head :not_found unless document.pdf.attached?

    send_data document.pdf.download,
      filename: document.filename,
      type: "application/pdf",
      disposition: "inline"
  end
end
