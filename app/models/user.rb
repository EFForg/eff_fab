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

  # this function returns the FAB due for the upcoming week, or builds it if
  # no such fab already exists
  def upcoming_fab
   # FIXME: this is a stub
    fabs.find_or_build_this_periods_fab
  end

  def next_or_previous_fab(fab_id, previous=false)
    current_period = Fab.find(fab_id).period

    if previous
      fab = fabs.where('period < ?', current_period).first
    else
      fab = fabs.where('period > ?', current_period).last
    end
  end

  def team_name
    return team.name if team
    "No Team"
  end

end
