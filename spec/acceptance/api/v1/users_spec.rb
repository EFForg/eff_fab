require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Onboarding New Employees" do
  header "Accept", "application/json"

  post "api/v1/users" do
    let(:body) { JSON.parse(response_body) }

    parameter :username, "The EFF-wide username; the part before '@eff.org' in their email", scope: :user
    parameter :email, "Their EFF email. Either email or username must be present.", scope: :user
    parameter :personal_emails, "Any extra email addresses they use", required: false, scope: :user
    parameter :staff, "Should they get a FAB? Defaults to true.", required: false, scope: :user

    let(:user) { User.last }
    let(:username) { "#{Faker::Name.first_name}.#{Faker::Name.last_name}".downcase }
    let(:extra_attrs) { {} }
    let(:raw_post) do
      {  user: { name: "Test User", username: username }.merge(extra_attrs) }
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
        expect(user.email).to eq("#{username}@eff.org")
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
    parameter :email, "The user's EFF email.  Either email or username must be present.", scope: :user
    parameter :username, "The EFF-wide username; the part before '@eff.org' in their email", scope: :user

    let!(:user) { FactoryGirl.create(:user, email: "Faker::Internet.user_name@eff.org") }
    let(:username) { user.email.split('@').first }
    let(:raw_post) { {  user: { username: username } } }

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
