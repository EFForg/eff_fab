require "rails_helper"

RSpec.describe PtoMailer, type: :mailer do
  describe "remind" do
    let!(:user) { FactoryGirl.create(:user) }
    let(:mail) { described_class.remind(user).deliver }

    it "sends email to specified user" do
      expect { mail }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(mail.to).to include(user.email)
    end

    context "matches HR's spec" do
      specify { expect(mail.subject).to eq("Log PTO") }
      specify { expect(mail.body.encoded).to include("reminder to log your paid leave") }
      specify { expect(mail.body.encoded).to include("https://eff.bamboohr.com/home") }
    end
  end
end
