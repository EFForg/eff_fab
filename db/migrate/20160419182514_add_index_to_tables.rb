class AddIndexToTables < ActiveRecord::Migration
  def change
    add_index :users, :team_id
    add_index :fabs, :user_id
    add_index :fabs, :period
    add_index :notes, :fab_id
  end
end
