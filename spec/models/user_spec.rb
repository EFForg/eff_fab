describe User do

  before :each do
    stub_time!

    @user = User.new(email: 'user@example.com')
  end

  subject { @user }

  it { should respond_to(:email) }

  it "#email returns a string" do
    expect(@user.email).to match 'user@example.com'
  end

  it "should be able to retrieve the upcoming fab" do
    fab = @user.upcoming_fab
    expect(fab.period).to eq @expected_period_beginning
  end

end
