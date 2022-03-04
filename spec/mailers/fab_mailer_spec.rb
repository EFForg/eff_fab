require "rails_helper"

RSpec.describe FabMailer, type: :mailer do

  describe 'reminder' do
    it 'sends a reminder email' do
      user = FactoryBot.create(:user)

      expect { FabMailer.remind(user).deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "Last minute reminder" do
    let(:user) { FactoryBot.create(:user) }
    let(:mail) { FabMailer.last_minute_remind(user) }

    it 'sends a last minute reminder' do
      expect { mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'should list off everyone who missed FAB this round on their team' do
      other1 = FactoryBot.create(:user)
      other2 = FactoryBot.create(:user)
      user.fabs << FactoryBot.create(:fab_due_in_current_period)


      expect(mail.subject).to match("[FAB] Some members of your team are fab flunking!")
      expect(mail.body).to match(other1.name)
      expect(mail.body).to match(other2.name)
    end
  end

  describe 'report_on_aftermath' do
    it 'sends a shaming' do
      user = FactoryBot.create(:user)

      expect { FabMailer.report_on_aftermath(user).deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

end
