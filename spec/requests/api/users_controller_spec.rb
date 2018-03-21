require 'rails_helper'

describe 'Users API', :type => :request do

  before :each do
    @admin = FactoryGirl.create(:user_admin)
    http_login @admin
  end

  it 'Creates users via API' do
    post '/api/users', {:user => attributes_for(:user)}, @env
    expect(response.status).to eq(201)
    expect(User.count).to eq 2
  end

  it 'Destroys users via API' do
    @user = FactoryGirl.create(:user)
    delete "/api/users", {email: @user.email}, @env
    expect(response.status).to eq(200)
    expect(User.count).to eq 1
  end
end
