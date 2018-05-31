require 'net/imap'
require 'mail'

class Wherebot
  TRASH = "Trash".freeze
  INBOX = "eff-where".freeze
  WHEREBOT_ORIGIN ="where@eff.org".freeze

  class << self
    def update_wheres(destructive: false)
      @destructive = destructive
      create_new_imap
      sign_into_wheremail
      import_emails
      clean_up
    end

    def forget_old_messages
      old = WhereMessage.where('sent_at < ?', 30.days.ago)

      if old.present?
        puts "destroying #{old.count} old messages."
      else
        puts "no old messages."
      end

      old.destroy_all
    end

    private

    def create_new_imap
      # create a fresh new instance of IMAP for the current import.
      @imap = Net::IMAP.new(
        ENV['INCOMING_MAIL_SERVER'], ENV['INCOMING_MAIL_PORT'], true
      )
      puts "connected to IMAP" if @imap.is_a?(Net::IMAP)
      @imap
    end

    def sign_into_wheremail
      @imap.login(ENV['WHEREBOT_USER_NAME'], ENV['WHEREBOT_PASSWORD'])
      puts "logged into Wheremail"
      @imap.examine(INBOX)
    end

    def import_emails
      new = @imap.search(["UNSEEN"])
      total = new.count
      done = 0

      puts "importing #{total} new messages"
      new.each do |id|
        Wherebot::Message.new(@imap, id, @destructive).create
        done += 1
        percent = done * 100.0 / total
        puts "#{percent.floor}%" if percent > 1 && (percent % 10) == 0
      end

      puts "import complete!"
    end

    def clean_up
      @imap.expunge if @destructive
      @imap.logout
      @imap.disconnect
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
        provenance: WHEREBOT_ORIGIN, sent_at: date, user: user
      )
      wm.body = body

      destroy_message if wm.save!
    rescue Exception => e
      Raven.extra_context(email: from, subject: subject, body: body)
      Raven.captureException(e)
      false
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

    def user
      User.find_by(email: from) ||
        User.where("personal_emails like ?", "%#{from.first}%").find do |user|
          (user.personal_emails & from).any?
        end
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

      true
    end
  end
end
