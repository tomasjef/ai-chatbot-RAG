class Assistant < ApplicationRecord
  has_many :knowledge_entries, dependent: :destroy
  has_many :documents, dependent: :destroy

  def profile_key
    name.to_s.parameterize.presence || "default"
  end
end
