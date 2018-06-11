require 'rails_helper'

RSpec.describe WhereMessage, type: :model do
  it 'has a user' do
    expect(FactoryGirl.create(:where_message).user).to be_a(User)
  end

  it 'must have either a body or a subject' do
    where = FactoryGirl.build(:where_message, subject: '', body: '')
    expect(where).not_to be_valid
  end

  describe "#ensure_sent_at" do
    let(:whereabout) { FactoryGirl.build(:where_message, sent_at: sent_at) }

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
