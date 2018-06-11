class AddSubjectToWheres < ActiveRecord::Migration
  def change
    add_column :where_messages, :subject, :string, default: ''

    reversible do |dir| 
      dir.up do 
        execute("UPDATE where_messages SET subject = ''")
      end
    end
  end
end
