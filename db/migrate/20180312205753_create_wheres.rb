class CreateWheres < ActiveRecord::Migration
  def change
    create_table :wheres do |t|
      t.integer :user_id
      t.datetime :sent_at
      t.text :body
      t.string :provenance

      t.timestamps
    end
  end
end
