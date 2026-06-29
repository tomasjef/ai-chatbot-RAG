class Assistant < ApplicationRecord
  has_many :knowledge_entries, dependent: :destroy
  has_many :documents, dependent: :destroy
end
