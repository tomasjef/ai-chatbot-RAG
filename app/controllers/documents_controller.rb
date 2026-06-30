class DocumentsController < ApplicationController
  before_action :authenticate_demo_access

  def show
    document = Document.find(params[:id])

    if document.pdf.attached?
      return send_data document.pdf.download,
        filename: document.filename,
        type: "application/pdf",
        disposition: "inline"
    end

    if (path = document.bundled_pdf_path)
      return send_file path,
        filename: document.filename,
        type: "application/pdf",
        disposition: "inline"
    end

    head :not_found
  rescue ActiveStorage::FileNotFoundError
    retry_without_attachment(document)
  end

  private

  def retry_without_attachment(document)
    return head :not_found unless (path = document.bundled_pdf_path)

    send_file path,
      filename: document.filename,
      type: "application/pdf",
      disposition: "inline"
  end
end
