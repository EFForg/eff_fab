require 'rails_helper'
require 'commands'

describe Api::V1::MattermostController do
  let(:body) { JSON.parse(response.body) }

  describe "#create" do
    let(:user) { FactoryGirl.create(:user, email: "cool.kittens@eff.org") }
    let(:username) { user.email.split("@").first }
    let(:text) { Faker::ChuckNorris.fact.parameterize('+') }
    let(:auth_token) { "let_me_in_ok" }
    let(:mattermost_team) { "the_real_deal" }
    let(:command) { "/where" }
    let(:extra_params) { {} }
    let(:slash_params) do
      # https://docs.mattermost.com/developer/slash-commands.html
      {
        format: :json, command: command, text: text, user_name: username
      }.merge(extra_params)
    end

    subject(:create) { post :create, slash_params }

    before do
      ENV['MATTERMOST_DOMAIN'] = mattermost_team
      ENV['MATTERMOST_TOKEN_WHERE'] = auth_token
    end

    it "fails" do
      expect(Commands).not_to receive(:new)
      create
      expect(response.status).to eq(401)
    end

    context "when Mattermost's token is present" do
      let(:command_args) do
        { user_name: username, text: text, command: command, token: auth_token }
      end
      let(:new_command) { Commands.run(command_args) }
      let(:responder) { double(:responder, response: command_response) }
      let(:command_response) { { 'response_text' => 'foo', 'response_type' => 'bar' } }
      let(:extra_params) { { token: auth_token, team_domain: mattermost_team } }

      it "delegates to Commands" do
        expect(Commands).to receive(:run).with(command_args).and_return(new_command)
        expect(new_command).to receive(:response).and_call_original
        create

        # Mattermost needs these two keys to render a response
        expect(body.keys).to include("response_type", "text")
      end
    end
  end
end
