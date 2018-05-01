class ChangeUnicodeCollation < ActiveRecord::Migration
  def up
    execute(
      "ALTER DATABASE #{ENV['MYSQL_DATABASE']} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    )
    execute(
      "ALTER TABLE where_messages CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    )
  end

  def down
    # There is no down: there are emojis in the db now, and those can't hang with utf8.
    # But here's what it would have been:
    #execute(
      #"ALTER DATABASE eff_fab_dev CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    #)
    #execute (
      #"ALTER TABLE where_messages CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    #)
  end
end
