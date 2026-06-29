class Document < ApplicationRecord
  belongs_to :assistant
  has_many :knowledge_entries, dependent: :destroy
end
