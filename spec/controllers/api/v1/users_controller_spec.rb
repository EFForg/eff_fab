require 'rails_helper'

describe Api::V1::UsersController do
  let(:username) { Faker::Internet.user_name }
  let!(:admin) { FactoryGirl.create(:user_admin, :with_api_key) }
  subject(:post_request) do
    post :create, {
      username: username, personal_emails: extra_emails, format: :json
    }
  end

  before {
    @request.headers['Authorization'] = admin.access_token
  }

  describe "POST #create" do
    let(:extra_emails) { 2.times.map { Faker::Internet.email } }

    example "records extra emails" do
      expect { post_request }.to change(User, :count).by(1)
      expect(User.last.personal_emails).to match_array(extra_emails)
    end

    context "when user has extra emails" do
      let(:personal_emails) { [Faker::Internet.email] }
      let!(:user) do
        FactoryGirl.create(
          :user, email: "#{username}@eff.org", personal_emails: personal_emails
        )
      end

      it "adds the new emails" do
        post_request
        expect(user.reload.personal_emails).to match_array(
          [extra_emails].concat(personal_emails).flatten
        )
      end
    end
  end
end
