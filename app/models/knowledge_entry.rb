class KnowledgeEntry < ApplicationRecord
  belongs_to :assistant
  belongs_to :document, optional: true
  has_neighbors :embedding
end
