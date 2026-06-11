class Assistant < ApplicationRecord
  has_many :knowledge_entries, dependent: :destroy
end
