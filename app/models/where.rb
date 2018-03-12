class Where < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :body

  before_create :ensure_sent_at

  def ensure_sent_at
    sent_at = Time.now if sent_at.blank?
  end
end
