class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents do |t|
      t.references :assistant, null: false, foreign_key: true
      t.string :filename

      t.timestamps
    end
  end
end
