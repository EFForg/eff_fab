require "wherebot"

RSpec.describe Wherebot do
  def from_sender(email)
    email_parts = email.split("@")
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
          date: 2.weeks.ago.to_s, subject: "WFH wooo!", from: [from_sender(user.email)]
        ),
        "BODY[TEXT]" => 'AUW'
      })
    end
    let(:where2) do
      OpenStruct.new(id: 2, attr: {
        "ENVELOPE" => OpenStruct.new(
          date: 1.weeks.ago.to_s, subject: "WFHellmouth", from: [from_sender(user2.email)]
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

    it "cleans up after itself non-destructively" do
      expect(imap).not_to receive(:copy)
      expect(imap).not_to receive(:store)
      expect(imap).not_to receive(:expunge)
      expect(imap).to receive(:logout)
      expect(imap).to receive(:disconnect)

      update_wheres
    end

    context "in destructive mode" do
      let(:update_wheres) { described_class.update_wheres(destructive: true) }

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
    end

    # I don't get RSpec 3's pending logic.
    # TODO: Uncomment this when personal emails exist.
    #context "sent from a personal email" do
      #let(:user) { FactoryGirl.create(:user, personal_emails: ['also_me@me.com']) }
      #let(:where2) do
        #OpenStruct.new(id: 2, attr: {
          #"ENVELOPE" => OpenStruct.new(
            #date: Time.now.to_s,
            #subject: "PTO EOM",
            #from: [from_sender(user2.personal_emails.first)]
          #)
        #})
      #end

      #it "assigns where_message to the correct user" do
        #expect { update_wheres }.to change(user.where_messages, :count).by(1)
      #end
    #end
  end

  describe 'Wherebot::Message.body' do
    let(:wherebot_message) { Wherebot::Message.new(double(:imap), rand(1..100)) }
    let(:body) { wherebot_message.body }

    before do
      allow(wherebot_message).to receive(:full_body).and_return(message)
      allow(wherebot_message).to receive(:headers).and_return(double(subject: ""))
    end

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
      let(:message) do # this is no one's actual PGP key, just a mess of characters
        "PGRpdiBkaTotallyZGlzY2xvc3VyZTo\r\naGUgY29ySecuregdGhlIHB\r\nYmVsX3A9Noise8BfYnV0d==\r\n\r\n\r\n\r\n"
      end
      specify { expect(body).to be_empty }
    end

    context "when message is in MIME format" do
      let(:message) do
        "This is a multi-part message in MIME format.\r\n--------------2709SecureNoise\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Transfer-Encoding: 7bit\r\n\r\Preparing for the uprising, then restoring my depleted energy reserves. Back Tuesday!\r\n\r\n-- \r\Namey\r\nGrant Writer\r\nElectronic Frontier Foundation\r\n\r\n\r\n--------------kajsdk89KLJsecurityNoiselklLK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Transfer-Encoding: 7bit\r\n\r\n<html>\r\n  <head>\r\n\r\n    <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\">\r\n  </head>\r\n  <body text=\"#000000\" bgcolor=\"#FFFFFF\">\r\n    <p>Preparing for the uprising, then restoring my depleted energy reserves. Back\r\n      Tuesday!<br>\r\n    </p>\r\n    <pre class=\"moz-signature\" cols=\"72\">-- \r\Namey\r\nGrant Writer\r\nElectronic Frontier Foundation\r\n\r\n</pre>\r\n  </body>\r\n</html>\r\n\r\n--------------LKJLJKKJsecurityNoise89908LKJL--\r\n\r\n\r\n"
      end

      it "returns the important part" do
        expect(body).to eq(
          "Preparing for the uprising, then restoring my depleted energy reserves. Back Tuesday!"
        )
      end
    end

    context "when message is in OpenPGP/MIME format" do
      let(:message) do
        "This is an OpenPGP/MIME signed message (RFC 4880 and 3156)\r\n--\r\nContent-Type: multipart/mixed; boundary=\"\";\r\n protected-headers=\"v1\"\r\nFrom: Namey <namey@eff.org>\r\nTo: \"where@namey.org\" <where@namey.org>\r\nMessage-ID: <ba5@namey.org>\r\nSubject: Namey omw! eta 11:30\r\n\r\n--\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Language: en-US\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\nI jumped in a ball pit and then totally slept through my alarm, oh noes!=\r\n=2E\r\n--=20\rNamey\r\nTechnologist General, Electronic Frontier Foundation\r\nGPG: https://www.namey.org/files/key.txt\r\n\r\n\r\n--890987SecureNoise989087--\r\n\r\n\nContent-Type: application/pgp-signature; name=\"signature.asc\"\r\nContent-Description: OpenPGP digital signature\r\nContent-Disposition: attachment; filename=\"signature.asc\"\r\n\r\n-----BEGIN PGP SIGNATURE-----\r\n\LKLKJLKLK/0989898798++\r\r\r\n=V4eA\r\n-----END PGP SIGNATURE-----\r\n\r\n----\r\n\r\n\r\n"
      end

      it "returns the important part" do
        expect(body).to eq(
          "I jumped in a ball pit and then totally slept through my alarm, oh noes!"
        )
      end
    end

    context "when message is from K9 mail" do
      let(:message) do
        "------slkj8978KLJLsecurityNoise\r\nContent-Type: text/plain;\r\n charset=utf-8\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\nShould be back in the office within an hour\r\n--=20\r\nSent from my Android device with K-9 Mail=2E wherePlease excuse my brevity=\r\n=2E\r\n------LKJ987SecurityNoise\r\nContent-Type: text/html;\r\n charset=utf-8\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\nShould be back in the office within an hour<br>\r\n-- <br>\r\nSent from my Android device with K-9 Mail=2E wherePlease excuse my brevity=\r\n=2E\r\n------SLKJ987KLJSecurityNoise--\r\n\r\n\r\n"
      end
      it "returns only the good stuff" do
        expect(body).to eq(
          "Should be back in the office within an hour"
        )
      end
    end

    context "when message is only HTML" do
      let(:message) do
        "Content-Type: text/html;\r\n\tcharset=utf-8<html><head><meta http-equiv=3D\"Content-Type\" content=3D\"text/html; =\r\ncharset=3Dutf-8\"></head><body style=3D\"word-wrap: break-word; =\r\n-webkit-nbsp-mode: space; line-break: after-white-space;\" class=3D\"\"><div class=3D\"\"><br class=3D\"\"></div><div class=3D\"\">I will be OOO all next week.</div><div class=3D\"\">"
      end

      it "returns only the good stuff" do
        expect(body).to eq(
          "I will be OOO all next week."
        )
      end
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

    context  do
      #I don't know why, but this message was failing in a different way
      let(:message) do
        "Keep getting stuck in peanut butter. I think I'm just very\r\ntired.\r\n\r\n-- \r\nNamey\r\nPeanut Butter Coordinator\r\n815 Eddy Street\r\nSan Francisco, CA\r\n\r\nnamey.org/join\r\n\r\n\r\n\r\n"
      end
      it "returns only the good stuff" do
        expect(body).to eq(
          "Keep getting stuck in peanut butter. I think I'm just very tired."
        )
      end
    end
  end
end
