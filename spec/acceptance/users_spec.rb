require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Onboarding New Employees" do
  header "Accept", "application/json"

  post "api/v1/users" do
    parameter :username, "The EFF-wide username; the part before '@eff.org' in their email", required: true
    parameter :password, "A beefy and highly entropic string", required: true
    parameter :personal_email, "Any extra email addresses they use", required: false
    parameter :staff, "Should they get a FAB? Defaults to true.", required: false

    let(:username) { "#{Faker::Name.first_name}.#{Faker::Name.last_name}".downcase }
    let(:password) { Faker::Internet.password }
    let(:user) { User.last }

    example "Without authentication, you can't create a new employee" do
      expect { do_request }.not_to change(User, :count)
      expect(status).to eq(401)
    end

    context "authenticated requests" do
      let!(:admin) { FactoryGirl.create(:user_admin) }
      let(:auth) do
        "Basic #{Base64.encode64("#{admin.email.split("@").first}:#{admin.password}")}"
      end
      header "Authorization", :auth
      header "WWW-Authenticate", :auth

      example "Onboard a bare-bones user" do
        expect { do_request }.to change(User, :count).by(1)
        expect(user.email).to eq("#{username}@eff.org")
        expect(user.staff).to be_truthy

        expect(status).to eq(200)
        expect(response_body).to eq(user.to_json)
      end

      context "with extra emails" do
        let(:personal_email) { 2.times.map { Faker::Internet.email } }

        example "Onboard a user with personal emails" do
          expect { do_request }.to change(User, :count).by(1)
          expect(user.personal_emails).to match_array(personal_email)

          expect(status).to eq(200)
        end
      end

      context "with an explicit staff flag" do
        let(:staff) { [true, false].sample }

        example "Onboard a user without FABs" do
          expect { do_request }.to change(User, :count).by(1)
          expect(user.staff).to eq(staff)

          expect(status).to eq(200)
        end
      end
    end
  end
end
