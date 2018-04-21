require 'commands'

RSpec.describe Commands::WhereIs do
  let(:asker) { FactoryGirl.create(:user) }
  let(:user) { FactoryGirl.create(:user) }
  let(:extra_args) { {} }
  let(:args) do
    { user_name: asker.username, command: 'where_is', text: user.username }
      .merge(extra_args)
  end

  before { ENV['MATTERMOST_TOKEN_WHEREIS'] = 'valid_token' }

  describe ".response" do
    subject(:response_body) { described_class.new(args).response }

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

      context "when user is not found" do
        subject(:response_body) do
          described_class.new(
            {
              user_name: asker.username, command: "where_is", text: "nope"
            }.merge(extra_args)
          ).response
        end

        it "returns a friendly message" do
          expect(response_body[:text]).to match(/I couldn't find "nope"/)
        end
      end

      context "with no wheres" do
        before { WhereMessage.destroy_all }

        it "responds with a friendly message" do
          expect(response_body[:text]).to match(/#{user.name} hasn't set a where/)
        end

        it "responds with the necessary keys" do
          expect(response_body.keys).to match_array(
            [:response_type, :text, :username]
          )
        end
      end
    end
  end
end
