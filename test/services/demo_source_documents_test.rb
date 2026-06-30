require "test_helper"

class DemoSourceDocumentsTest < ActiveSupport::TestCase
  QUESTION_PHRASES = [
    "Check my balance",
    "Transfer limits",
    "Dispute a charge",
    "Wire transfer fees",
    "Lost or stolen card",
    "Reset my PIN"
  ].freeze

  TERMS_PHRASES = [
    "These terms and using your HALO account",
    "How to contact HALO",
    "Keeping the account and app secure",
    "Available balance, Pots, and overdrafts",
    "International payments and foreign currency",
    "Account restrictions and account closure",
    "Changes to these terms",
    "Complaints",
    "Deposit protection"
  ].freeze

  test "included source PDFs cover every suggested question" do
    documents = Dir[Rails.root.join("db/source_pdfs/halo/*.pdf")].sort
    text = documents.map { |path| PdfTextService.call(path) }.join("\n")

    assert_equal 5, documents.size
    QUESTION_PHRASES.each do |phrase|
      assert_includes text, phrase
    end

    TERMS_PHRASES.each do |phrase|
      assert_includes text, phrase
    end
  end
end
