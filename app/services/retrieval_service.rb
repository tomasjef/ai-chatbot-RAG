class RetrievalService
  def self.call(assistant, question, limit: 5)
    new.call(assistant, question, limit: limit)
  end

  def call(assistant, question, limit:)
    query_embedding = EmbeddingService.call(question)

    assistant.knowledge_entries
      .joins(document: :pdf_attachment)
      .nearest_neighbors(:embedding, query_embedding, distance: "cosine")
      .first(limit)
  end
end
