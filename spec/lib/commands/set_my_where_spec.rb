require 'commands'

RSpec.describe Commands::SetMyWhere do
  let(:user) { FactoryGirl.create(:user, email: "cool.kitten@eff.org") }
  let(:body) { "WFC AUW EOM" }
  let(:extra_args) { {} }
  let(:args) do
    { user_name: user.username, text: body, command: 'set_my_where' }.merge(extra_args)
  end
  let(:command) { described_class.new(args) }

  before do
    ENV['MATTERMOST_TOKEN_WHERE'] = 'valid_token'
  end

  describe ".response" do
    subject(:response_body) { command.response }

    it "responds with failure" do
      expect(response_body.keys).to eq([:failure])
    end

    context "with valid token" do
      let(:extra_args) { { token: 'valid_token' } }

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
          "Your whereabouts are now set to \"#{body}\"."
        )
      end

      it "sets the username" do
        expect(response_body[:username]).to eq("Wherebot")
      end

      context "when user is not found" do
        subject(:response_body) do
          described_class.new(
            { user_name: "nope", command: "where_is" }.merge(extra_args)
          ).response
        end

        it "returns a friendly message" do
          expect(response_body[:text]).to match(/I couldn't save your message/)
        end
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
end
