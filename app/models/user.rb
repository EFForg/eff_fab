class User < ActiveRecord::Base
  enum role: [:user, :vip, :admin]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :team
  has_many :fabs

  # accepts_nested_attributes_for :fabs

  # this function returns the FAB due for the upcoming week, or builds it if
  # no such fab already exists
  def upcoming_fab
   # FIXME: this is a stub
    fabs.find_or_create_this_periods_fab
  end

  # job title for the user
  def title
    #FIXME: this is a stub
    "Art Director"
  end

  def team_name
    #FIXME: this is a stub
    return team.name if team
    "No Team"
  end

end
