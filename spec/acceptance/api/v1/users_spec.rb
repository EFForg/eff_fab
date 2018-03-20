require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Onboarding New Employees" do
  header "Accept", "application/json"

  post "api/v1/users" do
    let(:body) { JSON.parse(response_body) }

    parameter :email, required: true, scope: :user
    parameter :personal_emails, "Any extra email addresses they use", required: false, scope: :user
    parameter :staff, "Should they get a FAB? Defaults to true.", required: false, scope: :user

    let(:user) { User.last }
    let(:extra_attrs) { {} }
    let(:raw_post) do
      {  user: { name: "Test User", email: Faker::Internet.email }.merge(extra_attrs) }
    end

    example "Without authentication, you can't create a new employee" do
      expect { do_request }.not_to change(User, :count)
      expect(response_body["success"]).to be_falsey
      expect(status).to eq(401)
    end

    context "authenticated requests" do
      let!(:admin) { FactoryGirl.create(:user_admin, :with_api_key) }
      let(:auth) { admin.access_token }

      header "Authorization", :auth

      example "Onboard a bare-bones user" do
        expect { do_request }.to change(User, :count).by(1)
        expect(user.staff).to be_truthy

        expect(status).to eq(201)
        expect(body["success"]).to be_truthy
        expect(body["user"]).to eq(user.to_json)
      end

      context "with extra emails" do
        let(:extra_emails) { 2.times.map { Faker::Internet.email } }
        let(:extra_attrs) { { personal_emails: extra_emails } }

        example "Onboard a user with personal emails" do
          expect { do_request }.to change(User, :count).by(1)
          expect(user.personal_emails).to match_array(extra_emails)

          expect(status).to eq(201)
        end
      end

      context "with an explicit staff flag" do
        let(:extra_attrs) { { staff: false } }

        example "Onboard a user without FABs" do
          expect { do_request }.to change(User, :count).by(1)
          expect(user.staff).to eq(false)

          expect(status).to eq(201)
        end
      end
    end
  end

  delete "/api/v1/users" do
    parameter :email, "The user's EFF email", required: true

    let!(:user) { FactoryGirl.create(:user) }
    let(:email) { user.email }

    example "Without authentication, you can't destroy a user" do
      expect { do_request }.not_to change(User, :count)
      expect(response_body["success"]).to be_falsey
      expect(status).to eq(401)
    end

    context "authenticated requests" do
      let!(:admin) { FactoryGirl.create(:user_admin, :with_api_key) }
      let(:auth) { admin.access_token }

      header "Authorization", :auth

      example 'With authentication, destroys a user' do
        expect { do_request }.to change(User, :count).by(-1)
        expect(status).to eq(200)
      end
    end
  end
end
