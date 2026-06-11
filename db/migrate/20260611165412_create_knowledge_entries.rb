class CreateKnowledgeEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :knowledge_entries do |t|
      t.string :title
      t.text :content
      t.string :category
      t.vector :embedding, limit: 1536

      t.timestamps
    end
  end
end
