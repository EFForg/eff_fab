require 'rails_helper'
require 'commands'

describe Api::V1::MattermostController do
  let!(:user) { FactoryGirl.create(:user, email: "cool.kittens@eff.org") }
  let(:username) { user.email.split("@").first }
  let(:auth_token) { "let_me_in_ok" }
  let(:slash_params) do
    # https://docs.mattermost.com/developer/slash-commands.html
    { command: command, text: text, token: auth_token, user_name: username, format: :json }
  end

  before do
    ENV['MATTERMOST_TOKEN_WHERE'] = auth_token
    ENV['MATTERMOST_TOKEN_WHEREIS'] = auth_token
  end

  shared_examples "mattermost command" do
    it "executes the correct command and returns info Mattermost expects" do
      expect(command).to receive(:new).with(
        { user_name: username, text: text, token: auth_token }
      ).and_call_original
      create

      # Mattermost needs these two keys to render a response
      expect(JSON.parse(response.body).keys).to include("response_type")
      expect(JSON.parse(response.body).keys).to include("text")
    end
  end

  describe "#where" do
    let(:text) { Faker::ChuckNorris.fact.parameterize('+') }
    let(:command) { Commands::Where }
    subject(:create) { post :where, slash_params }

    include_examples "mattermost command"
  end

  describe "#where_is" do
    let(:text) { user.username }
    let(:command) { Commands::WhereIs }
    subject(:create) { post :where_is, slash_params }

    include_examples "mattermost command"
  end
end
