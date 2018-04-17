require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Onboarding New Employees" do
  header "Accept", "application/json"

  post "api/v1/users" do
    let(:body) { JSON.parse(response_body) }

    parameter :username, "The EFF-wide username. The part before '@' in their email"

    let(:user) { User.last }
    let(:username) { "#{Faker::Name.first_name}.#{Faker::Name.last_name}".downcase }

    example 'Without authentication, fails' do
      explanation "If the Authorization header is missing, or does not correspond
        to an admin's API token, the request will fail.  Admins can generate and view
        a user's API token through their profile."
      expect { do_request }.not_to change(User, :count)
      expect(response_body["success"]).to be_falsey
      expect(status).to eq(401)
    end

    context "authenticated requests" do
      parameter :email, "Their EFF email. Either email or username must be present."
      parameter :personal_emails, "Any extra email addresses they use"
      parameter :staff, "Should they get a FAB? Defaults to true."
      parameter :name, "Their actual human name"
      parameter :role, "#{User::roles.keys.to_sentence(last_word_connector: ' or ')}. Defaults to user."
      parameter :title, "What does this person do at EFF?"

      let!(:admin) { FactoryGirl.create(:user_admin, :with_api_key) }
      let(:auth) { admin.access_token }
      let(:extra_emails) { 2.times.map { Faker::Internet.email } }
      let(:title) { "Pizzamancer" }
      let(:raw_post) do
        { name: "Test User", username: username,
          personal_emails: extra_emails,
          staff: false,
          role: 'admin',
          title: title
        }
      end

      header "Authorization", :auth

      example "Onboard a user" do
        explanation "Authentication requires sending an 'Authorization' header
          with an admin user's API token.  Admins can create and view an API
          token by visiting a user's profile.
          A username or email must be present; all other info is optional."
        expect { do_request }.to change(User, :count).by(1)
        expect(user.personal_emails).to match_array(extra_emails)
        expect(user.staff).to be_falsey
        expect(user.admin?).to be_truthy
        expect(user.title).to eq(title)
        expect(status).to eq(201)
      end

      context "when user already exists" do
        let!(:user) { FactoryGirl.create(:user, email: "#{username}@eff.org") }

        example "Update a user who already exists in the database" do
          explanation "If the username matches an existing user,
            that user will be updated."
          expect { do_request }.not_to change(User, :count)
          expect(user.reload.name).to eq(raw_post[:name])
        end
      end
    end
  end
end

resource "Offboarding previous employees" do
  delete "/api/v1/users" do
    parameter :username, "The EFF-wide username; the part before '@eff.org' in their email", scope: :user

    let!(:user) { FactoryGirl.create(:user, email: "#{username}@eff.org") }
    let(:username) { Faker::Internet.user_name }
    let(:raw_post) { { username: username } }

    example 'Without authentication, fails' do
      explanation "If the Authorization header is missing, or does not correspond
        to an admin's API token, the request will fail. Admins can generate and view
        a user's API token through their profile."
      expect { do_request }.not_to change(User, :count)
      expect(response_body["success"]).to be_falsey
      expect(status).to eq(401)
    end

    context "authenticated requests" do
      parameter :email, "The user's EFF email", scope: :user

      let!(:admin) { FactoryGirl.create(:user_admin, :with_api_key) }
      let(:auth) { admin.access_token }

      header "Authorization", :auth

      example "Removes a user from the database" do
        explanation "If an Authorization header containing a valid admin's API
          token is present, the specified user will be removed from the app.
          Either username or email must be present to identify the user."
        expect { do_request }.to change(User, :count).by(-1)
        expect(status).to eq(200)
      end
    end
  end
end
