class KnowledgeEntry < ApplicationRecord
  belongs_to :assistant
  belongs_to :document
  has_neighbors :embedding
end
