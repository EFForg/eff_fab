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

      context "when email can't be saved" do
        let(:failures) { 'WHERE_FAILURES' }
        let(:mail2) { Mail.new(body: "update", subject: "where") }
        let(:wherebot_message2) { Wherebot::Message.new(double(:imap), mail_id) }
        let(:bodies) { JSON.parse(ENV[failures]).map { |i| i['body'] } }

        before do
          allow(wherebot_message2).to receive(:mail).and_return(mail2)
          allow_any_instance_of(WhereMessage).to receive(:save).and_return(false)
        end

        it "saves email to an env variable" do
          expect { wherebot_message.create }.to change { ENV[failures] }
          expect(bodies).to  match_array [
            message_body(mail_subject, message)
          ]
        end

        context "when env variable already exists" do
          it "appends to the env variable" do
            expect { wherebot_message2.create }.to change { ENV[failures] }
            expect(bodies).to match_array [
              message_body(mail.subject, mail.body),
              message_body(mail2.subject, mail2.body)
            ]
          end
        end
      end

      # I don't get RSpec 3's pending logic.
      # TODO: Uncomment this when personal emails exist.
      #context "sent from a personal email" do
        #let(:user) { FactoryGirl.create(:user, personal_emails: ['also_me@me.com']) }
        #
        #it "assigns where_message to the correct user" do
          #expect { update_wheres }.to change(user.where_messages, :count).by(1)
        #end
      #end
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
