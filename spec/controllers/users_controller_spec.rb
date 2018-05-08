require 'rails_helper'

describe UsersController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:user_admin) }

  describe 'DELETE #destroy' do
    let(:destroy) { delete :destroy, { user_id: user.id, id: user.id } }

    before { sign_in admin }

    it 'deletes the user' do
      destroy
      expect(User.where(id: user.id)).to be_empty
    end

    it 'redirects to users list' do
      destroy
      expect(response).to redirect_to users_path
    end
  end
end
