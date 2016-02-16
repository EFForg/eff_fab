class Fab < ActiveRecord::Base
  has_attached_file :gif_tag,
    styles: { medium: "300x300>", thumb: "100x100>" },
    default_url: "/images/:style/missing.png"

  validates_attachment_content_type :gif_tag, content_type: /\Aimage\/.*\Z/

  belongs_to :user

  has_many :notes

  accepts_nested_attributes_for :notes, reject_if: :all_blank, :allow_destroy => true

end
