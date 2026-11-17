require "test_helper"

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  test "serves an uploaded PDF from the database" do
    document = assistants(:one).documents.create!(filename: "uploaded.pdf")
    document.create_stored_file!(data: "%PDF-1.4 uploaded")

    get document_path(document)

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_equal "%PDF-1.4 uploaded", response.body
  end

  test "a document with no PDF anywhere is not found" do
    document = assistants(:one).documents.create!(filename: "missing.pdf")

    get document_path(document)

    assert_response :not_found
  end
end
