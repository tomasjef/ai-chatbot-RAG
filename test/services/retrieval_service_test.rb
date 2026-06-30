require "test_helper"
require "stringio"

class RetrievalServiceTest < ActiveSupport::TestCase
  test "retrieves only entries backed by attached PDF documents" do
    assistant = assistants(:one)
    document = documents(:one)
    document.pdf.attach(io: StringIO.new("%PDF-1.4\n"), filename: "terms.pdf", content_type: "application/pdf")

    document_entry = knowledge_entries(:one)
    document_entry.update!(
      document: document,
      embedding: vector,
      title: "Uploaded PDF passage"
    )

    KnowledgeEntry.new(
      assistant: assistant,
      title: "Source-less passage",
      content: "This should never be used.",
      category: "curated",
      embedding: vector
    ).save!(validate: false)

    query_vector = vector
    with_singleton_method(EmbeddingService, :call, ->(_question) { query_vector }) do
      results = RetrievalService.call(assistant, "What does the document say?", limit: 5)

      assert_equal [ document_entry ], results
    end
  end

  private

  def vector
    @vector ||= Array.new(1_536, 0.0).tap { |values| values[0] = 1.0 }
  end

  def with_singleton_method(object, method_name, replacement)
    original = object.method(method_name)
    object.define_singleton_method(method_name, replacement)
    yield
  ensure
    object.define_singleton_method(method_name, original)
  end
end
