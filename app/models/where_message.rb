class WhereMessage < ActiveRecord::Base
  PROVENANCES = { mattermost: "Mattermost", where_email: "where@eff.org" }

  belongs_to :user

  validates_presence_of :user
  validate :has_body_or_subject

  before_create :ensure_sent_at

  def ensure_sent_at
    self.sent_at = Time.now if sent_at.blank?
  end

  private

  def has_body_or_subject
    return if body.present? || subject.present?
    errors.add(:base, 'must have non-blank body or subject')
  end
end
