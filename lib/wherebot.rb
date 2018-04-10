require 'net/imap'
require 'mail'

class Wherebot
  TRASH = "Trash".freeze
  INBOX = "eff-where".freeze
  WHEREBOT_ORIGIN ="where@eff.org".freeze

  class << self
    def update_wheres(destructive: false)
      imap = Net::IMAP.new(
        ENV['INCOMING_MAIL_SERVER'], ENV['INCOMING_MAIL_PORT'], true
      )

      sign_into_wheremail(imap)

      imap.search(["UNSEEN"]).each do |id|
        Wherebot::Message.new(imap, id, destructive).create
      end

      clean_up(imap, destructive)
    end

    def forget_old_messages
      WhereMessage.where('sent_at < ?', 30.days.ago).destroy_all
    end

    private

    def sign_into_wheremail(imap)
      imap.login(ENV['WHEREBOT_USER_NAME'], ENV['WHEREBOT_PASSWORD'])
      imap.examine(INBOX)
    end

    def clean_up(imap, destructive)
      imap.expunge if destructive
      imap.logout
      imap.disconnect
    end
  end

  class Message
    include ActionView::Helpers::SanitizeHelper

    delegate :subject, :from, :date, to: :mail

    def initialize(imap, email_id, destroy = false)
      @imap = imap
      @id = email_id
      @destroy = destroy
    end

    def create
      wm = WhereMessage.find_or_initialize_by(
        provenance: WHEREBOT_ORIGIN,
        sent_at: date,
        user: User.find_by(email: from)
      )
      wm.body = body

      if wm.save
        destroy_message
        true
      else
        Rails.logger.error e
        false
      end
    rescue => e
      Rails.logger.error e
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

    def mail
      @mail ||= Mail.new(@imap.fetch(@id, 'BODY.PEEK[]')[0].attr['BODY[]'])
    end

    def get_text
      message = mail
      message = message.parts[0] while message.multipart?
      body = message.body.decoded
      body = strip_tags(body) if message.content_type.try(:start_with?, "text/html")

      body
    end

    def strip_quotes_and_signatures_from(body)
      return unless body.present?

      has_eom = body.match(/.*eom.?/i) # EOM, eom, <eom>, ~eom~, etc
      return has_eom[0] if has_eom.present?

      body = (body ||= '').split("Sent from").first
      body = (body ||= '').split("\nOn").first
      body = (body ||= '').split(/--( ?)(\r?)\n|~~( ?)\n/).first
      body = (body ||= '').split(/Content-Language: en-../).last
      body = (body ||= '').split('********').first
      body ||= ''
    end

    def reject_encryption(body)
      # this message is either made up only of encryption,
      # or is insufferably sesquipedalian.
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
      return unless body.present?

      body.strip!
      %w(= % &).include?(body.last) ? body[0..-2] : body
    end

    def nice_subject
      nice_subject = subject || ''
      nice_subject.gsub!('[EFF-where] ', '')
      nice_subject
    end

    def destroy_message
      return unless @destroy

      @imap.copy(@id, TRASH)
      @imap.store(@id, "+FLAGS", [:Deleted])
    end
  end
end
