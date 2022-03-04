# Feature: Sign in
#   As a user
#   I want to sign in
#   So I can visit protected areas of the site
feature 'Sign in', :devise do
  given(:user) { FactoryBot.create(:user) }

  # Scenario: User can sign in with valid credentials
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  scenario 'user can sign in with valid credentials' do
    signin(user.email, user.password)
    expect(page).not_to have_css('a', text: 'Sign in')
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
  end

  # Scenario: User cannot sign in with wrong email
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong email
  #   Then I see an invalid email message
  scenario 'user cannot sign in with wrong email' do
    signin('invalid@email.com', user.password)
    expect(page).to have_css('a', text: 'Sign in')
    expect(find('#alert').text).to match(
      /#{I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'}/i
    )
  end

  # Scenario: User cannot sign in with wrong password
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong password
  #   Then I see an invalid password message
  scenario 'user cannot sign in with wrong password' do
    signin(user.email, 'invalidpass')
    expect(page).to have_css('a', text: 'Sign in')
    expect(find('#alert').text).to match(
      /#{I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'}/i
    )
  end
end
