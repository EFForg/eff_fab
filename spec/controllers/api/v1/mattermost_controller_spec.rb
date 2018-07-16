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
    ENV['MATTERMOST_TOKEN_ADDFABFORWARD'] = auth_token
    ENV['MATTERMOST_TOKEN_ADDFABBACK'] = auth_token
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

  describe "#set_my_where" do
    let(:text) { Faker::ChuckNorris.fact.parameterize('+') }
    let(:command) { Commands::SetMyWhere }
    subject(:create) { post :set_my_where, slash_params }

    include_examples "mattermost command"
  end

  describe "#where_is" do
    let(:text) { user.username }
    let(:command) { Commands::WhereIs }
    subject(:create) { post :where_is, slash_params }

    include_examples "mattermost command"
  end

  describe "#add_fab_back" do
    let(:text) { "This week I built a Mattermost bot to update FABs" }
    let(:command) { Commands::AddFabBack }
    subject(:create) { post :add_fab_back, slash_params }

    include_examples "mattermost command"
  end

  describe "#add_fab_forward" do
    let(:text) { "Next week I will built a giant bot to destroy the city" }
    let(:command) { Commands::AddFabForward }
    subject(:create) { post :add_fab_forward, slash_params }

    include_examples "mattermost command"
  end
end
