class ChangeToUtf8mb4 < ActiveRecord::Migration
  def change
    change_column :users, :email, :string, :default => "", :null => false, :limit => 191
    change_column :users, :reset_password_token, :string, :limit => 191
    adapter_type = connection.adapter_name.downcase.to_sym
    case adapter_type
    when :mysql2
      execute <<-SQL
        ALTER TABLE notes
        MODIFY COLUMN body
        text CHARACTER SET utf8mb4
      SQL
    end
  end
end
