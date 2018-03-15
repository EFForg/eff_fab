class RenameWhereTable < ActiveRecord::Migration
  def up
    rename_table :wheres, :where_messages
  end

  def down
    rename_table :where_messages, :wheres
  end
end
