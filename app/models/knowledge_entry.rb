class KnowledgeEntry < ApplicationRecord
  has_neighbors :embedding
end
