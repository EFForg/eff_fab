require 'rails_helper'

describe Api::V1::UsersController do
  let(:username) { Faker::Internet.user_name }
  let!(:admin) { FactoryBot.create(:user_admin, :with_api_key) }

  before {
    @request.headers['APIAuthorization'] = admin.access_token
  }

  describe "POST #create" do
    subject(:post_request) { post :create, params: { username: username } }

    it "creates a user" do
      expect { post_request }.to change(User, :count).by(1)
      expect(User.last.username).to eq(username)
    end

    context "with invalid info" do
      let(:response_body) { JSON.parse(response.body) }
      before { allow_any_instance_of(User).to receive(:valid?).and_return(false) }

      it "fails to create a user" do
        expect { post_request }.to change(User, :count).by(0)
        expect(response_body["success"]).to eq(false)
        expect(response_body.keys).to include("errors")
      end
    end

    describe "when user exists" do
      let(:user) { FactoryBot.create(:user, staff: false) }

      it "updates the user" do
        post :create, params: { username: user.username, staff: true }
        expect(response).to be_successful
        expect(user.reload.staff).to eq(true)
      end

      context "when user has personal emails" do
        let(:personal_emails) { 2.times.map { Faker::Internet.email } }
        let(:extra_emails) { "me@coolmail.net,me@evencoolermail.net" }
        let!(:user) do
          FactoryBot.create(
            :user,
            email: "#{username}@eff.org",
            personal_emails: personal_emails
          )
        end

        it "overwrites the existing emails with new emails" do
          post :create, params: { username: username, personal_emails: extra_emails }

          expect(User.last.personal_emails).to match_array(
            ["me@coolmail.net", "me@evencoolermail.net"]
          )
        end

        it "retains the existing emails if no new emails are present" do
          expect(user.reload.staff).to be_truthy

          post :create, params: { username: username, staff: false }

          expect(user.reload.personal_emails).to match_array(personal_emails)
          expect(user.reload.staff).to be_falsey
        end
      end

      context "without changes" do
        let(:personal_emails) { ['hi@ok.com', 'yes@also.com'] }
        let!(:user) { FactoryBot.create(:user, personal_emails: personal_emails) }
        let(:post_request) { post :create, params: { username: user.username } }

        it "does not update the user" do
          old_password = user.encrypted_password
          post_request
          expect(user.reload.encrypted_password).to eq(old_password)
        end

        it "does not overwrite the personal emails" do
          post_request
          expect(user.reload.personal_emails).to match_array(personal_emails)
        end
      end

      context "with invalid info" do
        let(:response_body) { JSON.parse(response.body) }
        before { allow_any_instance_of(User).to receive(:valid?).and_return(false) }

        it "fails to update the user" do
          post_request
          expect(response_body["success"]).to eq(false)
          expect(response_body.keys).to include("errors")
        end
      end
    end
  end
end
