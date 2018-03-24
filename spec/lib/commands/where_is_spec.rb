require 'commands'

RSpec.describe Commands::WhereIs do
  let(:user) { FactoryGirl.create(:user, email: "cool.kitten@eff.org") }
  let(:command) { described_class.new(username: user.username) }

  describe ".response" do
    before do
      2.times do
        user.where_messages.create(
          body: Faker::ChuckNorris.fact,
          provenance: WhereMessage::PROVENANCES.values.sample,
          sent_at: rand(1..4).days.ago
        )
      end
    end

    subject(:response_body) { command.response }

    it "responds with the most recent where" do
      expect(response_body[:text]).to eq(
        "#{user.name}'s last known whereabouts are: #{user.last_whereabouts.body}"
      )
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
