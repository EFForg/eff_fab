require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Onboarding New Employees" do
  header "Accept", "application/json"

  post "api/v1/users" do
    let(:body) { JSON.parse(response_body) }

    parameter :username, "The EFF-wide username. The part before '@' in their email", required: true
    parameter :email, "Their EFF email. Username is not required if email is present."
    parameter :personal_emails, "Any extra email addresses they use"
    parameter :staff, "Should they get a FAB? Defaults to true."
    parameter :name, "Their actual human name"
    parameter :role, "#{User::roles.keys.to_sentence(last_word_connector: ' or ')}. Defaults to user."
    parameter :title, "What does this person do at EFF?"

    header "APIAuthorization", :auth

    let!(:admin) { FactoryBot.create(:user_admin, :with_api_key) }
    let(:auth) { admin.access_token }
    let(:user) { User.last }
    let(:username) { "#{Faker::Name.first_name}.#{Faker::Name.last_name}".downcase }
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

    example "Onboard a user" do
      explanation "Authentication requires sending an 'APIAuthorization' header
        with an admin user's API token, in addition to the basic auth.
        Admins can create and view an API token by visiting a user's profile.
        A username or email must be present; all other info is optional."
      expect { do_request }.to change(User, :count).by(1)
      expect(user.personal_emails).to match_array(extra_emails)
      expect(user.staff).to be_falsey
      expect(user.admin?).to be_truthy
      expect(user.title).to eq(title)
      expect(status).to eq(201)
    end

    context "when user already exists" do
      let!(:user) { FactoryBot.create(:user, email: "#{username}@eff.org") }

      example "Update a user who already exists" do
        explanation "If the username matches an existing user,
          that user will be updated."
        expect { do_request }.not_to change(User, :count)
        expect(user.reload.name).to eq(raw_post[:name])
      end
    end
  end
end

resource "Offboarding previous employees" do
  delete "/api/v1/users" do
    parameter :username, "The EFF-wide username; the part before '@eff.org' in their email", required: true

    header "APIAuthorization", :auth

    let!(:user) { FactoryBot.create(:user, email: "#{username}@eff.org") }
    let(:username) { Faker::Internet.user_name }
    let(:raw_post) { { username: username } }
    let!(:admin) { FactoryBot.create(:user_admin, :with_api_key) }
    let(:auth) { admin.access_token }

    example "Removes a user from the database" do
      explanation "If basic auth in addition to an APIAuthorization header containing
        a valid admin's API token is present, the specified user will be removed from
        the app.  Either username or email must be present to identify the user."
      expect { do_request }.to change(User, :count).by(-1)
      expect(status).to eq(200)
    end
  end
end

resource "What is going wrong?" do
  delete "/api/v1/users" do
    parameter :username, "The EFF-wide username; the part before '@eff.org' in their email", required: true

    example_request 'APIAuthorization header is missing or wrong' do
      explanation "If the APIAuthorization header is missing, or does not correspond
        to an admin's API token, the request will fail. Admins can generate and view
        a user's API token through their profile."
      expect(response_body["success"]).to be_falsey
      expect(status).to eq(401)
    end
  end
end
