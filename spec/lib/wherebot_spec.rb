require "wherebot"

RSpec.describe Wherebot do
  def message_body(subj, message)
    "#{subj}\n#{message}"
  end

  describe "update_wheres" do
    let(:imap) do
      double(
        login: true, examine: true, logout: true, disconnect: true, expunge: true
      )
    end
    let(:mail_ids) { [1,2] }
    let(:creator) { double(create: true) }
    let(:update_wheres) { described_class.update_wheres }

    before do
      allow(Net::IMAP).to receive(:new).and_return(imap)
      allow(imap).to receive(:search).and_return(mail_ids)
      allow_any_instance_of(Wherebot::Message).to receive(:create)
    end

    after { update_wheres }

    it "signs into IMAP" do
      expect(imap).to receive(:login)
    end

    it "reads from the where inbox" do
      expect(imap).to receive(:examine).with("eff-where")
    end

    it "fetches all historic where emails" do
      expect(imap).to receive(:search).with(["UNSEEN"])
    end

    it "creates Wherebot::Messages" do
      expect(Wherebot::Message).to receive(:new).exactly(mail_ids.count).times
        .and_return(creator)
      expect(creator).to receive(:create).exactly(mail_ids.count).times
    end

    it "cleans up after itself non-destructively" do
      expect(imap).not_to receive(:expunge)
      expect(imap).to receive(:logout)
      expect(imap).to receive(:disconnect)
    end

    context "in destructive mode" do
      let(:update_wheres) { described_class.update_wheres(destructive: true) }

      it "closes the connection" do
        expect(imap).to receive(:expunge)
        expect(imap).to receive(:logout)
        expect(imap).to receive(:disconnect)
      end
    end
  end

  describe "forget_old_messages" do
    let!(:new) { FactoryGirl.create(:where_message, sent_at: 29.days.ago) }
    let!(:old) { FactoryGirl.create(:where_message, sent_at: 31.days.ago) }

    it "destroys old where messages, but not new ones" do
      expect(WhereMessage.where("sent_at < ?", 30.days.ago)).to include(old)
      expect { Wherebot.forget_old_messages }.to change(WhereMessage, :count).by(-1)
      expect(WhereMessage.where("sent_at < ?", 30.days.ago)).to be_empty
    end
  end

  describe 'Wherebot::Message' do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail_subject) { "#{user.name} on the way!" }
    let(:message) { "OMW AUW EOM" }
    let(:mail_id) { rand(1..100) }
    let(:mail) do
      Mail.new(body: message, subject: mail_subject, date: Time.now, from: [user.email])
    end
    let(:imap) { double(copy: true, store: true) }
    let(:wherebot_message) { Wherebot::Message.new(imap, mail_id) }

    before do
      allow(wherebot_message).to receive(:mail).and_return(mail)
    end

    describe ".create" do
      let(:create) { wherebot_message.create }

      it "concatenates the subject and body" do
        expect(wherebot_message.body).to eq(message_body(mail_subject, message))
      end

      it "finds the where_message's owner by email address" do
        expect { create }.to change(user.where_messages, :count).by(1)
      end

      it "does not trash the read messages" do
        expect(imap).not_to receive(:copy)
        expect(imap).not_to receive(:store)

        create
      end

      context "in destructive mode" do
        let(:wherebot_message) { Wherebot::Message.new(imap, mail_id, true) }

        it "trashes the read messages" do
          expect(imap).to receive(:copy).with(mail_id, "Trash")
          expect(imap).to receive(:store).with(mail_id, "+FLAGS", [:Deleted])

          create
        end
      end

      context "when email matches an existing record" do
        # probably, the body method has changed, so the same email has a new body
        let(:old_body) { "probably not as good" }
        let!(:old_email) do
          FactoryGirl.create(
            :where_message, body: old_body, sent_at: mail.date, user: user,
            provenance: Wherebot::WHEREBOT_ORIGIN
          )
        end

        it "does not create a new record" do
          expect { create }.not_to change(WhereMessage, :count)
        end

        it "updates the body" do
          create
          expect(old_email.body).not_to eq(old_email.reload.body)
          expect(old_email.reload.body).to include(mail.body.decoded)
        end
      end

      context "when email can't be saved" do
        before do
          allow_any_instance_of(WhereMessage).to receive(:save!).and_raise("oh no!")
        end

        it "skips the unsavable email and keeps going" do
          expect { wherebot_message.create }.not_to raise_error
        end

        it "tells Sentry about it" do
          expect(Raven).to receive(:captureException)
          wherebot_message.create
        end
      end

      context "sent from a personal email" do
        let(:email) { 'also_me@me.com' }
        let!(:user) { FactoryGirl.create(:user, personal_emails: ["pre_#{email}"]) }
        let!(:user2) { FactoryGirl.create(:user, personal_emails: [email]) }
        let!(:user3) { FactoryGirl.create(:user, personal_emails: ["3_#{email}"]) }
        let(:mail) { Mail.new(subject: mail_subject, from: [email]) }

        it "assigns where_message to the correct user" do
          expect { create }.to change(user2.where_messages, :count).by(1)
        end
      end
    end

    describe '.body' do
      let(:mail_subject) { '' }
      let(:body) { wherebot_message.body }

      context "when message is all dumb whitespace" do
        let(:message) { "\r\n\r\n\r\n" }
        specify { expect(body).to be_empty }
      end

      context "when message is just whitespace and signature" do
        let(:message) { "\r\n\r\nSent from my iPhone\r\n\r\n\r\n" }
        specify { expect(body).to be_empty }
      end

      context "when message is just signature" do
        let(:message) do
          "\r\n-- \r\nNamey <namey@namey.org>\r\Staff Technologist https://www.namey.org/\r\nElectronic Frontier Foundation https://www.namey.org/join\r\n815 Eddy\r\n\r\n\r\n"
        end
        specify { expect(body).to be_empty }
      end

      context "when message is just a PGP key" do
        let(:message) do
          "PGRpdiBkaTotallyZGlz\r\naGUgY29ySecuregGhlIHB\r\nYmVsX3A9Noise8BfYnV0d=="
        end
        specify { expect(body).to be_empty }
      end

      context "when message is mostly fine, but has whitespace crud," do
        let(:message) { "HTTPSing Everywhere.  AUW.\r\n\r\n\r\n" }
        it "strips off the whitespace" do
          expect(body).to eq("HTTPSing Everywhere. AUW.")
        end
      end

      context "when message replies to another message" do
        let(:message) do
          "leaving early.\r\n\r\n\r\nOn 3/21/18 4:52 PM, Namey wrote:\r\n>\r\n>\r\n\r\n\r\n\r\n"
        end
        it "returns only the new content" do
          expect(body).to eq("leaving early.")
        end

        context "with inline quotes" do
          let(:message) do
            "Re: Namey WFH today\n\r\nContent-Language: en-USoffline for a bit Thanks,********************************\r\nNamey\r\nCool Coordinator\r\nElectronic Frontier Foundation (EFF)\r\nPGP Fingerprint: S0M3 LTR5"
          end
          it "returns only the new content" do
            expect(body).to eq("offline for a bit Thanks,")
          end
        end
      end
    end
  end
end
