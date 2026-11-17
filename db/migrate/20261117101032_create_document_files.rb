# Uploaded PDFs live in the database: Heroku's disk is wiped on every restart.
class CreateDocumentFiles < ActiveRecord::Migration[8.1]
  def change
    create_table :document_files do |t|
      t.references :document, index: { unique: true }, null: false, foreign_key: { on_delete: :cascade }
      t.binary :data, null: false

      t.timestamps
    end
  end
end
