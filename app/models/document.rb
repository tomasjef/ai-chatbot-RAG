class Document < ApplicationRecord
  SOURCE_PDF_DIR = Rails.root.join("db/source_pdfs/halo")

  belongs_to :assistant
  has_many :knowledge_entries, dependent: :destroy
  has_one_attached :pdf

  def source_available?
    pdf.attached? || bundled_pdf_path.present?
  end

  def bundled_pdf_path
    name = filename.to_s
    return if name.blank? || name != File.basename(name)

    path = SOURCE_PDF_DIR.join(name)
    path if path.file?
  end
end
