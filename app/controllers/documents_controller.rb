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
      return send_bundled_pdf(path)
    end

    head :not_found
  rescue ActiveStorage::FileNotFoundError
    retry_without_attachment(document)
  end

  private

  def retry_without_attachment(document)
    return head :not_found unless (path = document.bundled_pdf_path)

    send_bundled_pdf(path)
  end

  def send_bundled_pdf(path)
    send_data path.binread,
      filename: path.basename.to_s,
      type: "application/pdf",
      disposition: "inline"
  end
end
