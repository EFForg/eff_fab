require "wherebot"

RSpec.describe Wherebot do
  def from_sender(user)
    email_parts = user.email.split("@")
    OpenStruct.new(
      name: user.name, mailbox: email_parts.first, host: email_parts.second
    )
  end

  describe "update_wheres" do
    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:imap) do
      double(
        :imap, login: true, examine: true, logout: true, disconnect: true,
        copy: true, store: true, expunge: true
      )
    end
    let(:where1) do
      OpenStruct.new(id: 1, attr: {
        "ENVELOPE" => OpenStruct.new(
          date: 2.weeks.ago.to_s, subject: "WFH wooo!", from: [from_sender(user)]
        ),
        "BODY[TEXT]" => 'AUW'
      })
    end
    let(:where2) do
      OpenStruct.new(id: 2, attr: {
        "ENVELOPE" => OpenStruct.new(
          date: 1.weeks.ago.to_s, subject: "WFHellmouth", from: [from_sender(user2)]
        ),
        "BODY[TEXT]" => 'EOM'
      })
    end

    let(:update_wheres) { described_class.update_wheres }

    before do
      # stub the whole family of IMAP objects
      allow(Net::IMAP).to receive(:new).and_return(imap)
      allow(imap).to receive(:search).and_return([where1.id, where2.id])
      allow(imap).to receive(:fetch).with(where1.id, anything).and_return([where1])
      allow(imap).to receive(:fetch).with(where2.id, anything).and_return([where2])
    end

    it "fetches all historic where emails" do
      expect(imap).to receive(:search).with(["UNSEEN"])
      update_wheres
    end

    it "finds the where_message's owner by email address" do
      update_wheres
      expect(user.where_messages.count).to eq(1)
      expect(user2.where_messages.count).to eq(1)
    end

    it "saves subject and body to WhereMessage" do
      update_wheres
      expect(user.where_messages.first.body).to include("WFH wooo!")
      expect(user.where_messages.first.body).to include("AUW")
      expect(user2.where_messages.first.body).to include("WFHellmouth")
      expect(user2.where_messages.first.body).to include("EOM")
    end

    it "trashes the read messages and closes the connection" do
      expect(imap).to receive(:copy).with(where1.id, "Trash")
      expect(imap).to receive(:copy).with(where2.id, "Trash")
      expect(imap).to receive(:store).with(where1.id, "+FLAGS", [:Deleted])
      expect(imap).to receive(:store).with(where2.id, "+FLAGS", [:Deleted])
      expect(imap).to receive(:expunge)
      expect(imap).to receive(:logout)
      expect(imap).to receive(:disconnect)

      update_wheres
    end

    context "in demo mode" do
      let(:update_wheres) { described_class.update_wheres(destructive: false) }

      it "cleans up after itself non-destructively" do
        expect(imap).not_to receive(:copy)
        expect(imap).not_to receive(:store)
        expect(imap).not_to receive(:expunge)
        expect(imap).to receive(:logout)
        expect(imap).to receive(:disconnect)

        update_wheres
      end
    end
  end
end
