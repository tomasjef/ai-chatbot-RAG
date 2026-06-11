class RetrievalService
  def self.call(question, limit: 5)
    new.call(question, limit: limit)
  end

  def call(question, limit:)
    query_embedding = EmbeddingService.call(question)
    KnowledgeEntry
      .nearest_neighbors(:embedding, query_embedding, distance: "cosine")
      .first(limit)
  end
end
