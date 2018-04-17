require 'rails_helper'
require 'commands'

describe Api::V1::MattermostController do
  let!(:user) { FactoryGirl.create(:user, email: "cool.kittens@eff.org") }
  let(:username) { user.email.split("@").first }
  let(:text) { Faker::ChuckNorris.fact.parameterize('+') }
  let(:auth_token) { "let_me_in_ok" }
  let(:mattermost_team) { "the_real_deal" }
  let(:team_id) { "something_real" }
  let(:mattermost_ip) { '127.238.349' }
  let(:slash_params) do
    # https://docs.mattermost.com/developer/slash-commands.html
    # Also passes channel_id, channel_name, user_id and response_url
    {
      command: command,
      team_domain: mattermost_team,
      team_id: team_id,
      text: text,
      token: auth_token,
      user_name: username
    }.merge(format: :json)
  end

  before do
    ENV['MATTERMOST_DOMAIN'] = mattermost_team
    ENV['MATTERMOST_TEAM_ID'] = team_id
    ENV['MATTERMOST_TOKEN_WHERE'] = auth_token
    ENV['MATTERMOST_TOKEN_WHEREIS'] = auth_token
    ENV['MATTERMOST_IPS'] = "#{mattermost_ip} some.other.ip"
    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip)
      .and_return(mattermost_ip)
  end

  shared_examples "fails" do
    it "fails" do
      create
      expect(response.status).to eq(401)
    end
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

    context "without team name" do
      before { slash_params[:team_domain] = "something_bogus" }

      include_examples "fails"
    end

    context "without team id" do
      before { slash_params[:team_id] = "something_bogus" }

      include_examples "fails"
    end

    context "from a non-mattermost IP" do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip)
          .and_return("1.2.3.4")
      end

      include_examples "fails"
    end
  end

  describe "#where" do
    let(:command) { Commands::Where }
    subject(:create) { post :where, slash_params }

    include_examples "mattermost command"
  end

  describe "#where_is" do
    let(:command) { Commands::WhereIs }
    subject(:create) { post :where_is, slash_params }

    include_examples "mattermost command"
  end
end
