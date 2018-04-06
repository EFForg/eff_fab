require 'commands'

RSpec.describe Commands::WhereIs do
  let(:user) { FactoryGirl.create(:user, email: "cool.kitten@eff.org") }
  let(:extra_args) { {} }
  let(:args) { { user_name: user.username, command: 'where_is' }.merge(extra_args) }
  let(:command) { described_class.new(args) }

  before do
    ENV['MATTERMOST_TOKEN_WHEREIS'] = 'valid_token'
  end

  describe ".response" do
    subject(:response_body) { command.response }

    before do
      2.times do
        user.where_messages.create(
          body: Faker::ChuckNorris.fact,
          provenance: WhereMessage::PROVENANCES.values.sample,
          sent_at: rand(1..4).days.ago
        )
      end
    end

    it "responds with failure" do
      expect(response_body.keys).to eq([:failure])
    end

    context "with valid token" do
      let(:extra_args) { { token: 'valid_token' } }

      it "responds with the most recent where" do
        time = user.last_whereabouts.sent_at
        expect(response_body[:text]).to include(time.strftime('%-l:%M%P'))
        expect(response_body[:text]).to include(time.strftime('%m/%d/%y'))
        expect(response_body[:text]).to include(user.name)
        expect(response_body[:text]).to include(user.last_whereabouts.body)
      end

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
    end
  end
end
