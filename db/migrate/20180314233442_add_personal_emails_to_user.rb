class AddPersonalEmailsToUser < ActiveRecord::Migration
  def change
    add_column :users, :personal_emails, :text, array: true, default: []
  end
end
