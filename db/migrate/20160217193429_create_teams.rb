class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.text :name
      t.integer :weight

      t.timestamps null: false
    end
  end
end
