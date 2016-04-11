describe User do

  before :each do
    stub_time!

    @user = FactoryGirl.create(:user, email: 'user@example.com')
  end

  subject { @user }

  it { should respond_to(:email) }

  it "#email returns a string" do
    expect(@user.email).to match 'user@example.com'
  end

  it "should be able to retrieve the upcoming fab" do
    fab = @user.upcoming_fab
    expect(fab.period).to eq @expected_period_beginning
  end

  it "should be able to tell if a team mate didn't do their fab" do
    @other = FactoryGirl.create(:user, email: 'other@example.com')
    @user.fabs.find_or_build_this_periods_fab.save

    expect(@user.upcoming_fab_still_missing_for_team_mate?).to be true
  end

  it "should say no team mate's fabs are missing if it's only their own fab missing" do
    @other = FactoryGirl.create(:user, email: 'other@example.com')
    @other.fabs << FactoryGirl.create(:fab_due_in_current_period)

    expect(@user.upcoming_fab_still_missing_for_team_mate?).to be false
  end

  it "should say no team mate's are missing fabs if everyone did theirs" do
    @other = FactoryGirl.create(:user, email: 'other@example.com')
    @user.fabs << FactoryGirl.create(:fab_due_in_current_period)
    @other.fabs << FactoryGirl.create(:fab_due_in_current_period)

    expect(@user.upcoming_fab_still_missing_for_team_mate?).to be false
    expect(@other.upcoming_fab_still_missing_for_team_mate?).to be false
  end

  it "should tell when you're the only person on team missing fab" do
    @other = FactoryGirl.create(:user, email: 'other@example.com')
    expect(@user.only_person_of_team_missing_fab?).to be false

    @other.fabs << FactoryGirl.create(:fab_due_in_current_period)
    expect(@user.only_person_of_team_missing_fab?).to be true

    @user.fabs << FactoryGirl.create(:fab_due_in_current_period)
    expect(@user.only_person_of_team_missing_fab?).to be false
  end

  it "should have tested logic for user#get_fab_state" do
    @team_mate = FactoryGirl.create(:user)
    @outsider = FactoryGirl.create(:user, team_id: FactoryGirl.create(:team, name: 'meh').id)

    expect(@user.get_fab_state).to be :i_missed_fab

    @user.fabs << FactoryGirl.create(:fab_due_in_current_period)
    expect(@user.get_fab_state).to be :a_team_mate_missed_fab

    @team_mate.fabs << FactoryGirl.create(:fab_due_in_current_period)
    expect(@user.get_fab_state).to be :someone_on_staff_missed_fab

    @outsider.fabs << FactoryGirl.create(:fab_due_in_current_period)
    expect(@user.get_fab_state).to be :happy_fab_cake_time
  end

  it "should have has_missing_fab_for_period? show if missing" do
    period = Fab.get_start_of_current_fab_period

    expect(@user.has_missing_fab_for_period?(period)).to be_truthy

    @user.fabs << FactoryGirl.create(:fab_due_in_current_period)

    f = @user.fabs.first

    # this one was completed just outside the time range for when due (oh noez!)
    f.created_at = f.period + 1.week + Fab.n_hours_until_fab_due.hours + 1.minute
    f.save

    expect(@user.has_missing_fab_for_period?(period)).to be_truthy

    # this fab is now set with a created_at within the due range
    f.created_at = f.period + 1.week + Fab.n_hours_until_fab_due.hours - 1.minute
    f.save

    expect(@user.has_missing_fab_for_period?(period)).to be false
  end

  describe "#find_users_with_missing_fabs_current_period" do
    it "should find correct number of fab rogues" do

      r = User.find_users_with_missing_fabs_current_period
      expect(r.count).to eq 1

      @user.fabs << FactoryGirl.create(:fab_due_in_current_period)
      r = User.find_users_with_missing_fabs_current_period
      expect(r.count).to eq 0

    end
  end

end
