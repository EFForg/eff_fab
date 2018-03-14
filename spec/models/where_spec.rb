require 'rails_helper'

RSpec.describe Where, type: :model do
  let(:where) { FactoryGirl.create(:where) }

  it 'has a user' do
    expect(where.user).to be_a(User)
  end

  describe "#ensure_sent_at" do
    let(:whereabout) { FactoryGirl.build(:where, sent_at: sent_at) }

    context "when sent_at is present" do
      let(:sent_at) { 2.days.ago }

      it "does nothing" do
        whereabout.save
        expect(whereabout.sent_at.to_i).to eq(sent_at.to_i)
      end
    end

    context "when sent_at is nil" do
      let(:sent_at) { nil }

      it "sets sent_at to the time created" do
        whereabout.save
        expect(whereabout.sent_at.to_i).to eq(whereabout.created_at.to_i)
      end
    end
  end
end
