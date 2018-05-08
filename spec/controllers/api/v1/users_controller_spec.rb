require 'rails_helper'

describe Api::V1::UsersController do
  let(:username) { Faker::Internet.user_name }
  let!(:admin) { FactoryGirl.create(:user_admin, :with_api_key) }

  before {
    @request.headers['APIAuthorization'] = admin.access_token
  }

  describe "POST #create" do
    subject(:post_request) { post :create, { username: username } }

    it "creates a user" do
      expect { post_request }.to change(User, :count).by(1)
      expect(User.last.username).to eq(username)
    end

    context "with personal emails" do
      subject(:post_request) do
        post :create, { username: username, personal_emails: extra_emails }
      end

      context "when emails are an array" do
        let(:extra_emails) { 2.times.map { Faker::Internet.email } }

        it "records extra emails" do
          post_request
          expect(User.last.personal_emails).to match_array(extra_emails)
        end
      end

      context "when emails are a string" do
        let(:extra_emails) { "me@coolmail.net,me@evencoolermail.net" }

        it "records extra emails" do
          post_request
          expect(User.last.personal_emails).to match_array(
            ["me@coolmail.net", "me@evencoolermail.net"]
          )
        end
      end
    end

    describe "when user exists" do
      let(:user) { FactoryGirl.create(:user, staff: false) }

      it 'suceeds' do
        post :create, { username: user.username, staff: true }
        expect(response).to be_successful
        expect(user.reload.staff).to eq(true)
      end

      context "when user has personal emails" do
        let(:extra_emails) { "me@coolmail.net,me@evencoolermail.net" }
        let!(:user) do
          FactoryGirl.create(
            :user,
            email: "#{username}@eff.org",
            personal_emails: 2.times.map { Faker::Internet.email }
          )
        end

        it "overwrites them" do
          post :create, { username: username, personal_emails: extra_emails }

          expect(User.last.personal_emails).to match_array(
            ["me@coolmail.net", "me@evencoolermail.net"]
          )
        end
      end

      context "without changes" do
        # techOps uses this endpoint to create, update, and view users.
        let(:personal_emails) { ['hi@ok.com', 'yes@also.com'] }
        let!(:user) { FactoryGirl.create(:user, personal_emails: personal_emails) }
        let(:action) { post :create, username: user.username }

        it "does not update the user" do
          old_password = user.encrypted_password
          action
          expect(user.reload.encrypted_password).to eq(old_password)
        end

        it "does not overwrite the personal emails" do
          action
          expect(user.reload.personal_emails).to match_array(personal_emails)
        end
      end
    end
  end
end
