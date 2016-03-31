require 'rails_helper'

RSpec.describe Fab, type: :model do

  describe "easy stuff" do

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

      expected_forward = "Week of October 29th, 2001"
      expected_backward = "Week of October 22nd, 2001"
      expect(fab.display_forward_start_day).to eq expected_forward
      expect(fab.display_back_start_day).to eq expected_backward
    end

  end

  it "should be able to create a new fab the first time and query it the second time" do
    @user = FactoryGirl.create(:user)

    fab = @user.fabs.find_or_build_this_periods_fab

    fab.save
    fab.reload

    second_fab = @user.fabs.find_or_build_this_periods_fab

    expect(fab).to eq second_fab
  end

  it "should pull up a FAB within 24 hours of now if find_or_build_this_periods_fab is run Monday after 5PM" do
    allow(DateTime).to receive(:now) { DateTime.parse("Monday 4:59PM 2001-10-22") }

    @user = FactoryGirl.create(:user)
    fab = @user.fabs.find_or_build_this_periods_fab

    expect(fab.id).to be_nil
    fab.save

    fab = @user.fabs.find_or_build_this_periods_fab
    expect(fab.id).to be_truthy

    # roll forward past the due date
    allow(DateTime).to receive(:now) { DateTime.parse("Monday 5:01PM 2001-10-22") }
    fab = @user.fabs.find_or_build_this_periods_fab
    expect(fab.id).to be_nil
  end


  describe "advance_to_the_next_period_beginning" do

    it "should be able to find a Monday following a given Tuesday" do
      expected_difference_in_days = 6
      base_tuesday = DateTime.parse("Tuesday 5:01PM 2001-10-23")
      following_monday = nil

      Fab.instance_eval do
        following_monday = self.advance_to_the_next_period_beginning(base_tuesday)
      end

      expect((following_monday - base_tuesday).to_i).to eq expected_difference_in_days
    end

    it "should be able to find a Monday following a given Sunday" do
      expected_difference_in_days = 1
      base_day = DateTime.parse("Sunday 5:01PM 2001-10-21")
      following_monday = nil

      Fab.instance_eval do
        following_monday = self.advance_to_the_next_period_beginning(base_day)
      end

      expect((following_monday - base_day).to_i).to eq expected_difference_in_days
    end

  end

  describe "within_grace_period?" do

    it "should be within the grace period if it's after the fab_starting_day but before the fab_due_time" do
      allow(DateTime).to receive(:now) { DateTime.parse("Monday 4:59PM 2001-10-22") }
      are_we_within_grace_period = nil

      Fab.instance_eval do
        are_we_within_grace_period = self.within_grace_period?
      end

      expect(are_we_within_grace_period).to be_truthy
    end

    it "should not be in the grace period if it's just some random ass Sunday" do
      # allow(DateTime).to receive(:now) { DateTime.parse("Tuesday 4:59PM 2001-10-23") }
      allow(DateTime).to receive(:now) { DateTime.parse("Sunday 4:59PM 2001-10-21") }
      are_we_within_grace_period = nil

      Fab.instance_eval do
        are_we_within_grace_period = self.within_grace_period?
      end

      expect(are_we_within_grace_period).to be_falsy
    end

    it "should not be in the grace period if it's just some random ass Tuesday" do
      allow(DateTime).to receive(:now) { DateTime.parse("Tuesday 4:59PM 2001-10-23") }
      are_we_within_grace_period = nil

      Fab.instance_eval do
        are_we_within_grace_period = self.within_grace_period?
      end

      expect(are_we_within_grace_period).to be_falsy
    end

  end

  describe "which_neighbor_fabs_exist" do
    it "should be one previous fab and no next fab" do
      user = FactoryGirl.create(:user_with_yesterweeks_fab)
      fab = user.fabs.first
      a = fab.which_neighbor_fabs_exist?
      expect(a).to eq [true, false]
    end
  end

end

def stub_time!(t = DateTime.new(2001,10,26))
  allow(DateTime).to receive(:now) { t }
  @expected_period_beginning = YAML.load "--- !ruby/object:DateTime 2001-10-22 00:00:00.000000000 Z\n...\n"
end
