require 'commands'

RSpec.describe Commands::Where do
  let(:user) { FactoryGirl.create(:user, email: "cool.kitten@eff.org") }
  let(:body) { "WFC AUW EOM" }
  let(:args) { { user_name: user.username, text: body } }
  let(:command) { described_class.new(args) }

  describe ".response" do
    subject(:response_body) { command.response }

    it "creates a WhereMessage for the user" do
      expect { response_body }.to change(user.where_messages, :count).by(1)
      expect(WhereMessage.last.body).to eq(body)
    end

    it "responds with the necessary keys" do
      expect(response_body.keys).to match_array(
        [:response_type, :text, :username]
      )
    end

    it "sets the response_type" do
      expect(response_body[:response_type]).to eq("ephemeral")
    end

    it "sets the text" do
      expect(response_body[:text]).to eq(
        "Your whereabouts are now set to #{body}."
      )
    end

    it "sets the username" do
      expect(response_body[:username]).to eq("Wherebot")
    end

    context "failure" do
      before { allow_any_instance_of(WhereMessage).to receive(:save).and_return(false) }

      it "responds with the necessary keys" do
        expect(response_body.keys).to match_array(
          [:response_type, :text, :username]
        )
      end

      it "sets the response_type" do
        expect(response_body[:response_type]).to eq("ephemeral")
      end

      it "sets the username" do
        expect(response_body[:username]).to eq("Wherebot")
      end

      it "sets the text" do
        expect(response_body[:text]).to eq(
          "I couldn't save your message. Better send it it to where@eff.org :sweat_smile:"
        )
      end
    end
  end
end
