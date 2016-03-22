require 'rails_helper'

RSpec.describe Team, type: :model do

  before :each do
    create_standard_teams

    10.times { FactoryGirl.create(:user_with_completed_fab, team_id: Team.first.id) }
    6.times { FactoryGirl.create(:user_with_incompleted_fab, team_id: Team.first.id) }
  end

  it "has a way to get all users for a team where they have completed fabs" do
    runner_up_members = Team.get_runners

    expect(runner_up_members.count).to eq 6
  end

end
