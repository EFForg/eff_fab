require 'rails_helper'

RSpec.describe Fab, type: :model do

  describe "easy stuff" do

    before :each do
      stub_time!

      @user = FactoryGirl.create(:user)
    end

    it "should find or build fabs for the current period" do
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

  it "should pull up fabs logically via Fab#find_or_build_this_periods_fab" do
    allow(DateTime).to receive(:now) { ActiveSupport::TimeZone[ENV['time_zone']].parse("Thursday 2001-10-18 4:59PM") }

    @user = FactoryGirl.create(:user)
    fab = @user.fabs.find_or_build_this_periods_fab

    expect(fab.id).to be_nil
    # we're now going to save a FAB for the 8th
    fab.save

    # this will of course pull up that same fab
    fab = @user.fabs.find_or_build_this_periods_fab
    expect(fab.id).to be_truthy

    # roll forward into the following Friday
    allow(DateTime).to receive(:now) { ActiveSupport::TimeZone[ENV['time_zone']].parse("Friday 2001-10-19 1:01AM") }
    # this shouldn't pull up the prior fab, this should be a new fab
    fab = @user.fabs.find_or_build_this_periods_fab

    expect(fab.id).to be_nil
  end


  describe "advance_to_the_next_period_beginning" do

    # Not that this test was once confused by a daylight savings event taking
    # place in PST on first sunday of november
    it "should be able to find a Monday following a given Tuesday" do
      expected_difference_in_days = 6
      base_tuesday = ActiveSupport::TimeZone[ENV['time_zone']].parse("Tuesday 5:01PM 2001-10-23")
      following_monday = nil

      Fab.instance_eval do
        following_monday = self.advance_to_the_next_period_beginning(base_tuesday)
      end

      expect(following_monday.yday - base_tuesday.yday).to eq expected_difference_in_days
    end

    it "should be able to find a Monday following a given Sunday" do
      expected_difference_in_days = 1
      base_day = ActiveSupport::TimeZone[ENV['time_zone']].parse("Sunday 5:01PM 2001-10-21")
      following_monday = nil

      Fab.instance_eval do
        following_monday = self.advance_to_the_next_period_beginning(base_day)
      end

      expect(following_monday.yday - base_day.yday).to eq expected_difference_in_days
    end

  end

  describe "within_edit_period_of_old_fab?" do

    it "should show the fab for two mondays back if you navigate to /users on Thursday at 23:59" do
      reference_thursday_now = ActiveSupport::TimeZone[ENV['time_zone']].parse("Thursday 11:59PM 2001-10-25")

      # generates a fab for two_mondays_back from reference
      two_mondays_back = ActiveSupport::TimeZone[ENV['time_zone']].parse("Monday 4:59PM 2001-10-15")
      build_fab_for_specified_monday(two_mondays_back)

      fab_built_two_mondays_ago = @user.fabs.first

      allow(DateTime).to receive(:now) { reference_thursday_now }

      fab = @user.fabs.find_or_build_this_periods_fab
      expect(fab.period).to eq fab_built_two_mondays_ago.period
    end

    it "should show the fab for one Monday back if you navigate to the fabs after on Friday at 00:01" do
      one_monday_back = ActiveSupport::TimeZone[ENV['time_zone']].parse("Monday 4:59PM 2001-10-22")
      reference_friday_now = ActiveSupport::TimeZone[ENV['time_zone']].parse("Friday 1:01AM 2001-10-26")

      build_fab_for_specified_monday(one_monday_back)
      fab_for_one_monday_back = @user.fabs.first

      allow(DateTime).to receive(:now) { reference_friday_now }

      fab = @user.fabs.find_or_build_this_periods_fab
      expect(fab.period).to eq fab_for_one_monday_back.period
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

  describe "Fab#get_fab_state_for_period" do

    before :each do
      @user = FactoryGirl.create(:user)
      @team_mate = FactoryGirl.create(:user)
    end

    it "should have tested logic" do
      expect(Fab.get_fab_state_for_period).to be :someone_on_staff_missed_fab

      @user.fabs << FactoryGirl.create(:fab_due_in_current_period)
      @team_mate.fabs << FactoryGirl.create(:fab_due_in_current_period)
      expect(Fab.get_fab_state_for_period).to be :happy_fab_cake_time
    end

    it "should be able to work for arbitrary periods" do
      yesterweek_period = Fab.get_start_of_current_fab_period - 1.week
      expect(Fab.get_fab_state_for_period(yesterweek_period)).to be :someone_on_staff_missed_fab

      @user.fabs << FactoryGirl.create(:fab_due_in_prior_period)
      @team_mate.fabs << FactoryGirl.create(:fab_due_in_prior_period)

      expect(Fab.get_fab_state_for_period(yesterweek_period)).to be :happy_fab_cake_time
      expect(Fab.get_fab_state_for_period).to be :someone_on_staff_missed_fab
    end

    describe "tight timing logic" do
      before :each do
        @user.fabs << FactoryGirl.create(:fab_due_in_current_period)
        @team_mate.fabs << FactoryGirl.create(:fab_due_in_current_period)

        @exact_due_moment_of_fab = Fab.get_start_of_current_fab_period + 1.week + Fab.n_hours_until_fab_due.hours
      end

      it "shouldn't allow late fabs to count for cake" do
        @team_mate.fabs.first.update_attributes(created_at: @exact_due_moment_of_fab + 1.minute)

        expect(Fab.get_fab_state_for_period).to be :someone_on_staff_missed_fab
      end

      it "should allow fabs to count for cake if they're in 1 minute before due date" do
        @team_mate.fabs.first.update_attributes(created_at: @exact_due_moment_of_fab - 1.minute)

        expect(Fab.get_fab_state_for_period).to be :happy_fab_cake_time
      end
    end

  end

end
