require 'rails_helper'

describe FabsController, type: :controller do
  describe 'POST #create' do

    before :each do
      @user = FactoryGirl.create(:user)
      @other = FactoryGirl.create(:user)

      sign_in @user
    end

    context 'When authenticated correctly' do
      it 'creates the fab for self' do
        post :create, { user_id: @user.id, fab: { user_id: @user.id } }
        expect(Fab.count).to eq(1)
      end

      it 'redirects to the "show" action for the new fab' do
        post :create, { user_id: @user.id, fab: { user_id: @user.id } }
        expect(response).to redirect_to user_fab_path(@user, @user.fabs.first)
      end
    end

    context 'when not authenticated correctly' do
      it 'does not create a fab for a user other than you' do
        post :create, { user_id: @other.id, fab: { user_id: @other.id } }
        expect(Fab.count).to eq(0)
      end

      it 'does not create fabs for users when not even logged in' do
        sign_out @user
        post :create, { user_id: @user.id, fab: { user_id: @user.id } }
        expect(Fab.count).to eq(0)
      end
    end
  end

  describe 'DELETE #destroy' do

    before :each do
      @user = FactoryGirl.create(:user)
      @other = FactoryGirl.create(:user)

      sign_in @user
    end

    # Can't decide if this is ideal behavior...
    context 'When authenticated correctly' do

      it 'deletes the fab for self' do
        @user.fabs << FactoryGirl.create(:fab_due_in_prior_period)

        expect{
          delete :destroy, { user_id: @user.id, id: @user.fabs.first.id }
        }.to change{Fab.count}.from(1).to(0)
      end

      it 'redirects to the "show" action for the new fab' do
        post :create, { user_id: @user.id, fab: { user_id: @user.id } }
        expect(response).to redirect_to user_fab_path(@user, @user.fabs.first)
      end
    end

    context 'When not authenticated correctly' do
      it 'does not delete the fab for other' do
        @other.fabs << FactoryGirl.create(:fab_due_in_prior_period)

        expect{
          delete :destroy, { user_id: @other.id, id: @other.fabs.first.id }
        }.not_to change{Fab.count}
      end

      it 'does not delete a fab when not even logged in' do
        @user.fabs << FactoryGirl.create(:fab_due_in_prior_period)
        sign_out @user

        expect{
          delete :destroy, { user_id: @user.id, id: @user.fabs.first.id }
        }.not_to change{Fab.count}
      end
    end

  end

end
