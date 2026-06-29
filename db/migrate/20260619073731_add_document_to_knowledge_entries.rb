class AddDocumentToKnowledgeEntries < ActiveRecord::Migration[8.1]
  def change
    add_reference :knowledge_entries, :document, foreign_key: true
  end
end
