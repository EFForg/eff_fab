require 'rails_helper'

RSpec.describe Where, type: :model do
  let(:where) { FactoryGirl.create(:where) }

  it 'has a user' do
    expect(where.user).to be_a(User)
  end
end
