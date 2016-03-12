class User < ActiveRecord::Base
  enum role: [:user, :admin_user_mode, :admin]
  after_initialize :set_default_role, :if => :new_record?

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "60x90>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_associated :team

  belongs_to :team
  has_many :fabs
  has_one :current_period_fab,
    -> { where(period: Fab.get_start_of_current_fab_period..Fab.get_start_of_current_fab_period + 7.days) },
    class_name: "Fab"

  # this function returns the FAB due for the upcoming week, or builds it if
  # no such fab already exists
  def upcoming_fab
    fabs.find_or_build_this_periods_fab
  end

  def team_name
    return team.name if team
    "No Team"
  end

  def self.generate_password
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0...50).map { o[rand(o.length)] }.join
  end

end
