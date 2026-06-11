class KnowledgeEntry < ApplicationRecord
  belongs_to :assistant
  has_neighbors :embedding
end
