class WhereMessage < ActiveRecord::Base
  PROVENANCES = { mattermost: "Mattermost", where_email: "where@eff.org" }

  belongs_to :user

  validates_presence_of :user, :body

  before_create :ensure_sent_at

  def ensure_sent_at
    self.sent_at = Time.now if sent_at.blank?
  end
end
