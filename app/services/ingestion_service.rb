require "stringio"

class IngestionService
  def self.call(assistant, file_path, source_name:, attachable: nil)
    new.call(assistant, file_path, source_name: source_name, attachable: attachable)
  end

  def call(assistant, file_path, source_name:, attachable: nil)
    text = PdfTextService.call(file_path)
    chunks = ChunkingService.call(text)
    embeddings = chunks.map { |chunk| EmbeddingService.call(chunk) }

    ApplicationRecord.transaction do
      document = assistant.documents.create!(filename: source_name)
      attach_pdf(document, file_path, source_name, attachable)

      chunks.zip(embeddings).each.with_index(1) do |(chunk, embedding), index|
        assistant.knowledge_entries.create!(
          document: document,
          title: "#{source_name} (part #{index})",
          content: chunk,
          category: "document",
          embedding: embedding
        )
      end
    end

    chunks.size
  end

  private

  def attach_pdf(document, file_path, source_name, attachable)
    if attachable.present?
      document.pdf.attach(attachable)
    else
      document.pdf.attach(
        io: StringIO.new(File.binread(file_path)),
        filename: source_name,
        content_type: "application/pdf"
      )
    end
  end
end
