class Document < ApplicationRecord
  SOURCE_PDF_DIR = Rails.root.join("db/source_pdfs/halo")
  BUNDLED_PDFS = {
    "halo_account_balance_guide.pdf" => SOURCE_PDF_DIR.join("halo_account_balance_guide.pdf"),
    "halo_cards_pin_and_security.pdf" => SOURCE_PDF_DIR.join("halo_cards_pin_and_security.pdf"),
    "halo_current_account_terms_and_conditions.pdf" => SOURCE_PDF_DIR.join("halo_current_account_terms_and_conditions.pdf"),
    "halo_disputes_refunds_and_chargebacks.pdf" => SOURCE_PDF_DIR.join("halo_disputes_refunds_and_chargebacks.pdf"),
    "halo_payments_limits_and_fees.pdf" => SOURCE_PDF_DIR.join("halo_payments_limits_and_fees.pdf")
  }.freeze

  belongs_to :assistant
  has_many :knowledge_entries, dependent: :destroy
  has_one_attached :pdf

  def source_available?
    pdf.attached? || bundled_pdf_path.present?
  end

  def bundled_pdf_path
    path = BUNDLED_PDFS[filename.to_s]
    path if path.file?
  end
end
