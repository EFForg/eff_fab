class RemoveDefaultFromPersonalEmails < ActiveRecord::Migration
  def change
    change_column_default :users, :personal_emails, nil
  end
end
