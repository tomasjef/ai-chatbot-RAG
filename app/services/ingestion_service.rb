class IngestionService
  def self.call(assistant, file_path, source_name:)
    new.call(assistant, file_path, source_name: source_name)
  end

  def call(assistant, file_path, source_name:)
    text   = PdfTextService.call(file_path)
    chunks = ChunkingService.call(text)

    document = assistant.documents.create!(filename: source_name)

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
end
