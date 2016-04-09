require 'support/helpers/session_helpers'
RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
end


def stub_time!(t = ActiveSupport::TimeZone[ENV['time_zone']].parse("2001-10-26 0:00"))
  allow(DateTime).to receive(:now) { t }
  @expected_period_beginning = ActiveSupport::TimeZone[ENV['time_zone']].parse("2001-10-22 0:00")
end

def build_fab_for_specified_monday(monday)
  @user = FactoryGirl.create(:user)
  @user.fabs << FactoryGirl.create(:fab, period: monday)
end
