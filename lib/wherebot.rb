require 'net/imap'

class Wherebot
  TRASH = "Trash".freeze
  INBOX = "eff-where".freeze

  class << self
    def update_wheres(destructive: true)
      imap = Net::IMAP.new(
        ENV['incoming_mail_server'], ENV['incoming_mail_port'], true
      )

      sign_into_wheremail(imap)

      new_messages(imap).each do |id|
        Wherebot::Message.new(imap, id, destructive).create
      end

      clean_up(imap, destructive)
    end

    private

    def sign_into_wheremail(imap)
      imap.login(ENV['wherebot_user_name'], ENV['wherebot_password'])
      imap.examine(INBOX)
    end

    def new_messages(imap)
      @new_messages ||= imap.search(["UNSEEN"])
    end

    def clean_up(imap, destructive)
      imap.expunge if destructive
      imap.logout
      imap.disconnect
    end
  end

  class Message
    def initialize(imap, message_id, destroy)
      @imap = imap
      @id = message_id
      @destroy = destroy
    end

    def create
      WhereMessage.find_or_create_by(
        provenance: 'where@eff.org',
        sent_at: DateTime.parse(message.date),
        body: body_for(message),
        user: User.find_by(
          email: "#{message.from[0].mailbox}@#{message.from[0].host}"
        )
      )

      destroy_message
    end

    def message
     @message ||= @imap.fetch(@id, "ENVELOPE")[0].attr["ENVELOPE"]
    end

    def body_for(message)
      message.subject.gsub!('[EFF-where] ', '')

      body = if (subject = message.subject).split(' ').last.downcase == 'eom'
        subject
      else
        "#{subject}\n#{@imap.fetch(@id, 'BODY[TEXT]')[0].attr['BODY[TEXT]']}"
      end

      body.force_encoding('UTF-8')
    end

    def destroy_message
      if @destroy
        @imap.copy(@id, TRASH)
        @imap.store(@id, "+FLAGS", [:Deleted])
      end
    end
  end
end
