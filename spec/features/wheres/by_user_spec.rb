require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

RSpec.feature "A single user's whereabouts page", type: :feature do
  let(:user) { FactoryGirl.create(:user) }
  let!(:not_my_where) do
    FactoryGirl.create(:where_message, body: "someone else's status")
  end

  before(:each) do
    login_as(FactoryGirl.create(:user))
  end

  after { Warden.test_reset! }

  scenario "shows a cute little empty state" do
    visit user_wheres_path(user)
    expect(page).to have_content(I18n.t("shruggie"))
    expect(page).not_to have_css('table')
  end

  context "when the user has whereabouts" do
    let!(:my_where1) do
      FactoryGirl.create(:where_message, user: user, sent_at: 7.days.ago)
    end
    let!(:my_where2) do
      FactoryGirl.create(:where_message, user: user, sent_at: 6.days.ago)
    end
    let!(:my_where3) do
      FactoryGirl.create(:where_message, user: user, sent_at: 4.days.ago)
    end

    scenario "shows all the user's whereabouts" do
      visit user_wheres_path(user)
      expect(page).to have_css("table td", text: my_where1.body)
      expect(page).to have_css("table td", text: my_where1.body)
      expect(page).to have_css("table td", text: my_where2.body)
      expect(page).to have_css("table td", text: my_where3.body)
      expect(page).not_to have_content(not_my_where.body)
    end
  end
end
