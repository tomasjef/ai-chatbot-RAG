class Document < ApplicationRecord
  belongs_to :assistant
  has_many :knowledge_entries, dependent: :destroy
  has_one_attached :pdf
end
