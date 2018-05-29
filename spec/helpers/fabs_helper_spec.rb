RSpec.describe FabsHelper do
  describe "backward_or_placeholders(fab)" do
    let(:back1) { "hi" }
    let(:old_back1) { "just some strings" }
    let(:old_back2) { "just so we can assert equality" }
    let(:user) { FactoryGirl.create(:user) }
    let(:now) { Fab.get_start_of_current_fab_period }
    let!(:current_fab) { user.fabs.create(period: now) }
    let!(:prior_fab) { user.fabs.create(period: now - 1.week) }

    subject(:notes) { backward_or_placeholders(current_fab) }

    before do
      current_fab.backward.first.update(body: back1)
      current_fab.backward.second.update(body: "")
      prior_fab.forward.first.update(body: back1)
      prior_fab.forward.second.update(body: old_back1)
      prior_fab.forward.third.update(body: old_back2)
    end

    it "returns a unique list of this week's backwards and last week's forwards" do
      expect(notes).to match_array([back1, old_back1, old_back2])
    end

    context "when all backwards are filled out" do
      before do
        current_fab.backward.each {|note| note.update(body: Faker::ChuckNorris.fact) }
      end

      it "returns only the backwards" do
        expect(notes).to match_array(current_fab.backward.pluck(:body))
      end
    end
  end
end
