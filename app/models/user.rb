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

  before_save { |t| t.email = t.email.downcase }

  # this function returns the FAB due for the upcoming week, or builds it if
  # no such fab already exists
  def upcoming_fab
    fabs.find_or_build_this_periods_fab
  end

  def upcoming_fab_still_missing?(target_period = Fab.get_start_of_current_fab_period)
    has_missing_fab_for_period?(target_period)
  end

  def has_missing_fab_for_period?(target_period = Fab.get_start_of_current_fab_period)
    range = Fab.get_on_time_range_for_period(target_period)

    fabs.where(
      period: target_period,
      created_at: range).count == 0
  end

  def previous_fab_still_missing?
    upcoming_fab.exactly_previous_fab.new_record?
  end

  def self.fab_still_missing_for_someone?(target_period = Fab.get_start_of_current_fab_period)
    self.all.any? { |u| u.upcoming_fab_still_missing?(target_period) }
  end

  def upcoming_fab_still_missing_for_team_mate?
    return false if self.team.nil?
    self.team.users.any? { |u| u.upcoming_fab_still_missing? unless u.id == self.id }
  end

  def team_name
    return team.name if team
    "No Team"
  end

  # this function checks off the fab status for a given fab period
  def get_fab_state
    return :i_missed_fab if upcoming_fab_still_missing?
    return :a_team_mate_missed_fab if upcoming_fab_still_missing_for_team_mate?
    return :someone_on_staff_missed_fab if User.fab_still_missing_for_someone?
    return :happy_fab_cake_time
  end

  def self.generate_password
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0...50).map { o[rand(o.length)] }.join
  end

  def self.unfinished_fabs(target_period = nil)
    find_users_with_missing_fabs_current_period.count
  end

  def self.find_users_with_missing_fabs_current_period(target_period = nil)
    target_period = Fab.get_start_of_current_fab_period if target_period.nil?
    rogue_users = []

    self.all.each do |u|
      rogue_users << u if u.has_missing_fab_for_period?(target_period)
    end

    rogue_users
  end

  def only_person_of_team_missing_fab?
    upcoming_fab_still_missing? and !upcoming_fab_still_missing_for_team_mate?
  end

end
