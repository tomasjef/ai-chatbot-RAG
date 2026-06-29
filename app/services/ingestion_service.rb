class IngestionService
  def self.call(assistant, file_path, source_name:, attachable: nil)
    new.call(assistant, file_path, source_name: source_name, attachable: attachable)
  end

  def call(assistant, file_path, source_name:, attachable: nil)
    text   = PdfTextService.call(file_path)
    chunks = ChunkingService.call(text)

    document = assistant.documents.create!(filename: source_name)
    attach_pdf(document, file_path, source_name, attachable)

    chunks.each_with_index do |chunk, i|
      entry = assistant.knowledge_entries.build(
        document: document,
        title:    "#{source_name} (part #{i + 1})",
        content:  chunk,
        category: "document"
      )
      entry.embedding = EmbeddingService.call(chunk)
      entry.save!
    end

    chunks.size
  end

  private

  def attach_pdf(document, file_path, source_name, attachable)
    if attachable.present?
      document.pdf.attach(attachable)
    else
      File.open(file_path, "rb") do |file|
        document.pdf.attach(
          io: file,
          filename: source_name,
          content_type: "application/pdf"
        )
      end
    end
  end
end
