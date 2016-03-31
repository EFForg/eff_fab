require "rails_helper"

RSpec.describe FabMailer, type: :mailer do

  describe 'reminder' do
    it 'sends a reminder email' do
      user = FactoryGirl.create(:user)

      expect { FabMailer.remind(user).deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "Last minute reminder" do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { FabMailer.last_minute_remind(user) }

    it 'sends a last minute reminder' do
      expect { mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'should list off everyone who missed FAB this round on their team' do
      other1 = FactoryGirl.create(:user)
      other2 = FactoryGirl.create(:user)
      user.fabs.find_or_build_this_periods_fab.save

      expect(mail.subject).to match("Some members of your team are fab failing!")
      expect(mail.body.encoded).to match(other1.name)
      expect(mail.body.encoded).to match(other2.name)
    end
  end

  describe 'shame' do
    it 'sends a shaming' do
      user = FactoryGirl.create(:user)

      expect { FabMailer.shame(user).deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

end
