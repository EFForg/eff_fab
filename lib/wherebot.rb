require 'net/imap'
require 'mail'

class Wherebot
  TRASH = "Trash".freeze
  INBOX = "eff-where".freeze

  class << self
    def update_wheres(destructive: false)
      imap = Net::IMAP.new(
        ENV['INCOMING_MAIL_SERVER'], ENV['INCOMING_MAIL_PORT'], true
      )

      sign_into_wheremail(imap)

      new_messages(imap).each do |id|
        Wherebot::Message.new(imap, id, destructive).create
      end

      clean_up(imap, destructive)
    end

    private

    def sign_into_wheremail(imap)
      imap.login(ENV['WHEREBOT_USER_NAME'], ENV['WHEREBOT_PASSWORD'])
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
    def initialize(imap, email_id, destroy = false)
      @imap = imap
      @id = email_id
      @destroy = destroy
    end

    def create
      wm = WhereMessage.find_or_create_by(
        provenance: 'where@eff.org',
        sent_at: DateTime.parse(headers.date),
        user: User.find_by(
          email: "#{headers.from[0].mailbox}@#{headers.from[0].host}"
        )
      )
      if wm.update(body: body)
        destroy_message
      else
        store_failure(wm)
      end

    end

    def body
      body = get_text
      body = strip_quotes_and_signatures_from(body)
      body = reject_encryption(body)
      strip_junk_from(body)
      body = remove_trailing_junk(body)
      "#{nice_subject}\n#{body}".strip.chomp.force_encoding('UTF-8')
    end

    private

    def headers
      @headers ||= @imap.fetch(@id, "ENVELOPE")[0].attr["ENVELOPE"]
    end

    def full_body
      @full_body ||= @imap.fetch(@id, 'BODY[TEXT]')[0].attr['BODY[TEXT]']
    end

    def get_text
      body = full_body.split("Content-Type: text/")[1] || full_body
      body = body.split("Content-Transfer-Encoding: ")[1] || body

      if body.first(4) == "html"
        body = ActionController::Base.helpers.strip_tags(body) || body
      end

      body
    end

    def strip_quotes_and_signatures_from(body)
      has_eom = body.match(/.*eom.?/i)
      return has_eom[0] if has_eom.present?
      body = body.split("Sent from").first
      body = body.split("\nOn").first
      body = body.split('--').first
      body = body.split(/Content-Language: en-../).last
      body = body.split('********').first
    end

    def reject_encryption(body)
      # this message is either made up only of encryption,
      # or is insufferably sesquepedalian.
      body = '' if body.present? && body.split(' ').map(&:length).min > 10
      body
    end

    def strip_junk_from(body)
      return unless body.present?
      body.gsub!(/\n|\r/, ' ')
      body.gsub!('  ', ' ')
      body.remove!(/quoted-printable|\r\n|\n\r|=2E|7bit|html;|charset=utf-8/)
      body.strip!
    end

    def remove_trailing_junk(body)
      body.strip!

      if %w(= % &).include?(body.last)
        body[0..-2]
      else
        body
      end
    end

    def nice_subject
      subject = headers.subject
      subject.gsub!('[EFF-where] ', '')
      subject
    end

    def destroy_message
      if @destroy
        @imap.copy(@id, TRASH)
        @imap.store(@id, "+FLAGS", [:Deleted])
      end
    end

    def store_failure(where_message)
      storage = ENV['WHERE_FAILURES'].try(:dup).to_s

      if storage.empty?
        storage = [JSON.parse(where_message.to_json)]
      else
        storage = JSON.parse(storage) << JSON.parse(where_message.to_json)
      end

      ENV['WHERE_FAILURES'] = storage.to_json
    end
  end
end
