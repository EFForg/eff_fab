include Warden::Test::Helpers
Warden.test_mode!

feature 'Site navigation:', :devise do

  after(:each) do
    Warden.test_reset!
  end

  scenario "User can sign up, log in, or view FAB" do
    visit root_path

    expect(all('a').map {|a| a[:href] }.uniq).to match_array([
      root_path, users_path, new_user_session_path, new_user_registration_path
    ])
  end

  context "A signed-in user" do
    let(:user) { FactoryBot.create(:user) }
    let(:links) do
      [root_path, users_path, wheres_path, user_fabs_path(user.id),
       destroy_user_session_path, edit_user_path(user)]
    end

    before do
      login_as(user, scope: :user)
      visit root_path
    end

    scenario "can sign out, view FAB, or view Whereabouts" do
      expect(all('a').map {|a| a[:href] }.uniq).to match_array(links)
    end

    context "with admin permissions" do
      let(:user) { FactoryBot.create(:user_admin) }

      scenario "can sign out, administrate, view FAB, or view Whereabouts" do
        expect(all('a').map {|a| a[:href] }.uniq).to match_array(links + [admin_path])
      end
    end
  end
end
