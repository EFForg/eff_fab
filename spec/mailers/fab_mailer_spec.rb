require "rails_helper"

RSpec.describe FabMailer, type: :mailer do
  it 'sends an email' do
    user = FactoryGirl.create(:user)

    expect { FabMailer.reminder(user).deliver_now }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
