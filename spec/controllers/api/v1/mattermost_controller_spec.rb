require 'rails_helper'
require 'commands'

describe Api::V1::MattermostController do
  let(:body) { JSON.parse(response.body) }
  let!(:user) { FactoryGirl.create(:user, email: "cool.kittens@eff.org") }
  let(:username) { user.email.split("@").first }
  let(:text) { Faker::ChuckNorris.fact.parameterize('+') }
  let(:auth_token) { "let_me_in_ok" }
  let(:mattermost_team) { "the_real_deal" }
  let(:extra_params) { {} }
  let(:slash_params) do
    # https://docs.mattermost.com/developer/slash-commands.html
    {
      format: :json, text: text, user_name: username
    }.merge(extra_params)
  end
  # Mattermost needs these two keys to render a response
  let(:mattermost_keys) { ["response_type", "text"] }

  before do
    ENV['MATTERMOST_DOMAIN'] = mattermost_team
    ENV['MATTERMOST_TOKEN_WHERE'] = auth_token
    ENV['MATTERMOST_TOKEN_WHEREIS'] = auth_token
  end

  describe "#where" do
    subject(:create) { post :where, slash_params }

    it "fails" do
      create
      expect(response.status).to eq(401)
    end

    context "when Mattermost's token is present" do
      let(:command_args) { { user_name: username, text: text, token: auth_token } }
      let(:extra_params) { { token: auth_token, team_domain: mattermost_team } }

      it "delegates to the correct Commands subclass" do
        expect(Commands::Where).to receive(:new).with(command_args)
          .and_call_original
        create

        # Mattermost needs these two keys to render a response
        expect(body.keys).to include("response_type", "text")
      end
    end
  end

  describe "#where_is" do
    subject(:create) { post :where_is, slash_params }

    it "fails" do
      create
      expect(response.status).to eq(401)
    end

    context "when Mattermost's token is present" do
      let(:command_args) { { user_name: username, text: text, token: auth_token } }
      let(:extra_params) { { token: auth_token, team_domain: mattermost_team } }

      it "delegates to the correct Commands subclass" do
        expect(Commands::WhereIs).to receive(:new).with(command_args)
          .and_call_original
        create

        mattermost_keys.each do |key|
          expect(body.keys).to include(key)
        end
      end
    end
  end
end
