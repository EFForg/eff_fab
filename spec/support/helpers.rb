require 'support/helpers/session_helpers'
RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
end


def stub_time!(t = DateTime.new(2001,10,26))
  allow(DateTime).to receive(:now) { t }
  @expected_period_beginning = YAML.load "--- !ruby/object:DateTime 2001-10-22 00:00:00.000000000 Z\n...\n"
end

def build_fab_for_specified_monday(monday)
  @user = FactoryGirl.create(:user)
  @user.fabs << FactoryGirl.create(:fab, period: monday)
end
