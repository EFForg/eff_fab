class CreateFabs < ActiveRecord::Migration
  def change
    create_table :fabs do |t|
      t.integer :users_id

      t.timestamps null: false
    end

    add_attachment :fabs, :gif_tag
  end
end
