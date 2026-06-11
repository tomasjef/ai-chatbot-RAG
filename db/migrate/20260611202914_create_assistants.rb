class CreateAssistants < ActiveRecord::Migration[8.1]
  def change
    create_table :assistants do |t|
      t.string :name
      t.text :system_prompt

      t.timestamps
    end
  end
end
