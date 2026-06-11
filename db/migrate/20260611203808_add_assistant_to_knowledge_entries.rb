class AddAssistantToKnowledgeEntries < ActiveRecord::Migration[8.1]
  def change
    add_reference :knowledge_entries, :assistant, null: false, foreign_key: true
  end
end
