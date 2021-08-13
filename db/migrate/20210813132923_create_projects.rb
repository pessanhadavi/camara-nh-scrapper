class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :law
      t.text :law_url
      t.text :description
      t.string :apresentation_date
      t.string :author
      t.string :current_local
      t.string :status
      t.string :deadline
      t.string :last_processing
      t.string :last_action
      t.string :accessory_docs
      t.text :accessory_docs_url
      t.text :original_text

      t.timestamps
    end
  end
end
