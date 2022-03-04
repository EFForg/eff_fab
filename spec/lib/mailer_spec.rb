require "mailers"

RSpec.describe "mailer tasks" do
  let!(:staff) { FactoryBot.create(:user) }
  let!(:intern) { FactoryBot.create(:user, staff: false) }

  describe "turbo_remind" do
    before do
      allow(FabMailer).to receive(:remind).and_return(double(deliver_now: true))
    end

    it "includes staff members" do
      expect(FabMailer).to receive(:remind).with(staff)
      expect(FabMailer).not_to receive(:remind).with(intern)
      turbo_remind
    end
  end

  describe "turbo_last_minute_remind" do
    before do
      allow(FabMailer).to receive(:last_minute_remind).and_return(double(deliver_now: true))
    end

    it "includes staff members" do
      expect(FabMailer).to receive(:last_minute_remind).with(staff)
      expect(FabMailer).not_to receive(:last_minute_remind).with(intern)

      turbo_last_minute_remind
    end
  end

  describe "turbo_report_on_aftermath" do
    before do
      allow(FabMailer).to receive(:report_on_aftermath).and_return(double(deliver_now: true))
    end

    it "includes staff members" do
      expect(FabMailer).to receive(:report_on_aftermath).with(staff)
      expect(FabMailer).not_to receive(:report_on_aftermath).with(intern)

      turbo_report_on_aftermath
    end
  end
end
