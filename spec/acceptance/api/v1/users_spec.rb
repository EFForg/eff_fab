require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Onboarding New Employees" do
  header "Accept", "application/json"

  post "api/v1/users" do
    let(:body) { JSON.parse(response_body) }

    parameter :username, "The EFF-wide username. The part before '@' in their email"
    parameter :email, "Their EFF email. Either email or username must be present."
    parameter :personal_emails, "Any extra email addresses they use"
    parameter :staff, "Should they get a FAB? Defaults to true."
    parameter :name, "Their actual human name"
    parameter :role, "#{User::roles.keys.to_sentence(last_word_connector: ' or ')}. Defaults to user."
    parameter :title, "What does this person do at EFF?"

    let(:user) { User.last }
    let(:username) { "#{Faker::Name.first_name}.#{Faker::Name.last_name}".downcase }
    let(:extra_attrs) { {} }
    let(:raw_post) do
      {  name: "Test User", username: username }.merge(extra_attrs)
    end

    example "Without authentication, fails" do
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

      context "with extra info" do
        let(:extra_emails) { 2.times.map { Faker::Internet.email } }
        let(:title) { "Pizzamancer" }
        let(:extra_attrs) do
          {
            personal_emails: extra_emails,
            staff: false,
            role: 'admin',
            title: title
          }
        end

        example "Onboard a user with extra info" do
          expect { do_request }.to change(User, :count).by(1)
          expect(user.personal_emails).to match_array(extra_emails)
          expect(user.staff).to eq(false)
          expect(user.admin?).to be_truthy
          expect(user.title).to eq(title)

          expect(status).to eq(201)
        end
      end

      context "when user already exists" do
        let!(:user) { FactoryGirl.create(:user, email: "#{username}@eff.org") }
        let(:new_name) { Faker::Name.name }
        let(:raw_post) do
          {  name: new_name, username: username }
        end

        example "Update users who already exist in the database" do
          expect { do_request }.not_to change(User, :count)
          expect(user.reload.name).to eq(new_name)
        end
      end
    end
  end
end

resource "Offboarding previous employees" do
  delete "/api/v1/users" do
    parameter :email, "The user's EFF email.  Either email or username must be present.", scope: :user
    parameter :username, "The EFF-wide username; the part before '@eff.org' in their email", scope: :user

    let!(:user) { FactoryGirl.create(:user, email: "Faker::Internet.user_name@eff.org") }
    let(:username) { user.email.split('@').first }
    let(:raw_post) { { username: username } }

    example 'Without authentication, fails' do
      expect { do_request }.not_to change(User, :count)
      expect(response_body["success"]).to be_falsey
      expect(status).to eq(401)
    end

    context "authenticated requests" do
      let!(:admin) { FactoryGirl.create(:user_admin, :with_api_key) }
      let(:auth) { admin.access_token }

      header "Authorization", :auth

      example 'With authentication, succeeds' do
        expect { do_request }.to change(User, :count).by(-1)
        expect(status).to eq(200)
      end
    end
  end
end
