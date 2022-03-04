 include Warden::Test::Helpers
 Warden.test_mode!

 feature 'User profile page', :devise do
   let(:user) { FactoryBot.create(:user, :with_api_key, email: 'user@eff.org') }

   after(:each) do
     Warden.test_reset!
   end

   scenario 'user sees own profile' do
     login_as(user)
     visit user_path(user)
     expect(page).to have_content 'User'
     expect(page).to have_content user.email
     expect(page).to have_content user.access_token
   end

   scenario "user cannot see another user's API key" do
     me = FactoryBot.create(:user)
     login_as(me)
     visit user_path(user)
     expect(page).to have_content 'User'
     expect(page).to have_content user.email
     expect(page).not_to have_content user.access_token
   end

 end
