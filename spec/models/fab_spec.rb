require 'rails_helper'

RSpec.describe Fab, type: :model do

  before :each do
    stub_time!

    @user = FactoryGirl.create(:user)
  end

  it "should find our build fabs for the current period" do
    fab = @user.fabs.find_or_build_this_periods_fab

    expect(fab.period).to eq @expected_period_beginning
  end

  it "should make 3 forward and 3 backward notes when created" do
    fab = @user.fabs.find_or_build_this_periods_fab

    fab.save

    expect(fab.notes.count).to eq 6
    expect(fab.forward.count).to eq 3
    expect(fab.backward.count).to eq 3
  end

  it "should display time spans well" do
    fab = @user.fabs.find_or_build_this_periods_fab

    expected_forward = "October 29, 2001 - November  2, 2001"
    expected_backward = "October 22, 2001 - October 26, 2001"
    expect(fab.display_forward_time_span).to eq expected_forward
    expect(fab.display_back_time_span).to eq expected_backward
  end

end

def stub_time!
  t = DateTime.new(2001,10,26)
  allow(DateTime).to receive(:now) { t }
  @expected_period_beginning = YAML.load "--- !ruby/object:DateTime 2001-10-22 00:00:00.000000000 Z\n...\n"
  
end
