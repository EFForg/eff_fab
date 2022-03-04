require 'rails_helper'

describe ToolsController, type: :controller do
  describe 'POST #populate_this_weeks_fabs' do
    let(:admin) { FactoryBot.create(:user_admin) }
    let!(:staff) { FactoryBot.create(:user) }
    let!(:intern) { FactoryBot.create(:user, staff: false) }
    subject(:action) { post :populate_this_weeks_fabs }

    before { sign_in admin }

    it "creates a FAB for each staff member" do
      expect { action }.to change(staff.fabs, :count)
    end

    it "ignores non-staff users" do
      expect { action }.not_to change(intern.fabs, :count)
    end

    it 'redirects to admin' do
      action
      expect(response).to redirect_to admin_path
    end
  end
end
