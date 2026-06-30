require "test_helper"
require "tempfile"

class IngestionServiceTest < ActiveSupport::TestCase
  test "creates a pdf backed document and entries from extracted chunks" do
    assistant = assistants(:one)
    embedding = vector
    pdf = Tempfile.new([ "source", ".pdf" ])
    pdf.binmode
    pdf.write("%PDF-1.4\n")
    pdf.rewind

    with_singleton_method(PdfTextService, :call, ->(_path) { "PDF text" }) do
      with_singleton_method(ChunkingService, :call, ->(_text) { [ "First chunk", "Second chunk" ] }) do
        with_singleton_method(EmbeddingService, :call, ->(_chunk) { embedding }) do
          assert_equal 2, IngestionService.call(assistant, pdf.path, source_name: "source.pdf")
        end
      end
    end

    document = assistant.documents.find_by!(filename: "source.pdf")
    assert_predicate document.pdf, :attached?
    assert_equal [ "source.pdf (part 1)", "source.pdf (part 2)" ],
      document.knowledge_entries.order(:title).pluck(:title)
  ensure
    pdf&.close
    pdf&.unlink
  end

  private

  def vector
    Array.new(1_536, 0.0)
  end

  def with_singleton_method(object, method_name, replacement)
    original = object.method(method_name)
    object.define_singleton_method(method_name, replacement)
    yield
  ensure
    object.define_singleton_method(method_name, original)
  end
end
