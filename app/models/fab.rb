class Fab < ActiveRecord::Base
  has_attached_file :gif_tag,
    styles: { medium: "300x300>", thumb: "100x100>" },
    default_url: "/images/:style/missing.png"

  validates_attachment_content_type :gif_tag, content_type: /\Aimage\/.*\Z/

  default_scope { order('period DESC') }

  belongs_to :user
  has_many :notes
  has_many :forward, -> { where(forward: true).order(:id) }, class_name: "Note"
  has_many :backward, -> { where(forward: false).order(:id) }, class_name: "Note"


  accepts_nested_attributes_for :notes, reject_if: :all_blank, :allow_destroy => true

  after_initialize :setup_children

  def self.find_or_build_this_periods_fab
    fab_attrs = {period: get_start_of_current_fab_period..get_start_of_current_fab_period+6.days}
    self.where(fab_attrs).first || self.new(period: get_start_of_current_fab_period)
  end

  # careful to only call this when you know the user doesn't have a fab this period...
  def self.build_this_periods_fab
    self.new(period: get_start_of_current_fab_period)
  end

  # If it's Thursday, should return the date of two mondays ago
  # if it's Friday, it should return the monday of the current week!!!
  def self.get_start_of_current_fab_period
    # should we show the old fab or a new one
    start_day = if within_edit_period_of_old_fab?
      # return the date for the prior week's fab entry so...
      # (go back 7 days, then go forward until the first Monday) (potentially jumping back more than 7 days!)
      (DateTime.now.in_time_zone.midnight - 2.week)
    else
      # return the date for the current weeks fab entry so...
      # (go back 7 days from now, then go forward until the first Monday)
      (DateTime.now.in_time_zone.midnight - 1.week)
    end

    start_day = advance_to_the_next_period_beginning(start_day)
  end

  def self.n_hours_until_fab_due
    ActiveSupport::TimeZone[ENV['time_zone']].parse(ENV['fab_due_time']).hour
  end

  def self.get_on_time_range_for_period(start_of_period)
    hours_until_due = n_hours_until_fab_due
    (start_of_period..start_of_period+1.week+hours_until_due.hours)
  end

  def self.get_fab_state_for_period(target_period = Fab.get_start_of_current_fab_period)
    User.fab_still_missing_for_someone?(target_period) ? :someone_on_staff_missed_fab : :happy_fab_cake_time
  end

  def to_s
    forwards = forward.collect {|n| n.body}.join(", ")
    backwards = backward.collect {|n| n.body}.join(", ")
    " Backwards: #{backwards} \n Forwards: #{forwards}"
  end

  def setup_children
    if new_record? and notes.empty?
      3.times { notes.build(forward: true) }
      3.times { notes.build(forward: false) }
    end
  end

  def expose_notes(direction)
    if self.new_record?
      notes = [
        OpenStruct.new({ body: direction == "forward" ? "=(" : "This user hasn't filled out this FAB!" }),
        OpenStruct.new({ body: "" }),
        OpenStruct.new({ body: "" })
      ]
    else
      case direction
      when "forward"
        forward
      when "back"
        backward
      end
    end
  end

  # Returns "Week of March 28th, 2016"
  def display_back_start_day
    display_start_day_of_week(period)
  end

  def display_forward_start_day
    display_start_day_of_week(period + 1.week)
  end

  def present_start_day_for_week(is_forward)
    is_forward ? display_forward_start_day : display_back_start_day
  end

  def display_date_for_header
    self.period.strftime("%b %-d ") + "-" + (self.period + 4.days).strftime(" %-d")
  end

  # this function can be used as a seek forward and will skip blank fabs
  def previous_fab
    self.user.fabs.where('period < ?', self.period).first
  end

  # this function can be used as a seek forward
  def next_fab
    fab = self.user.fabs.where('period > ?', self.period).last
  end

  # this function tries to return the exact next fab for the user, or returns nil
  def exactly_next_fab(include_hypothetical_fab = true)
    fab = self.user.fabs.where(period: period+1.week-1.day..period+2.weeks-1.day).last
    fab = self.user.fabs.build(period: period+1.week) if include_hypothetical_fab and fab.nil?
    fab
  end

  # this function tries to return the exact previous fab for the user, or returns nil
  def exactly_previous_fab(include_hypothetical_fab = true)
    fab = self.user.fabs.where(period: period+1.day-2.week..period+1.day-1.week).last
    fab = self.user.fabs.build(period: period-1.week) if include_hypothetical_fab and fab.nil?
    fab
  end


  # returns an array of two, indicating true or false whether there's a previos
  # or next fab relative to the fab_id supplied
  def which_neighbor_fabs_exist?
    [!self.previous_fab.nil?, !self.next_fab.nil?]
  end

  def self.advance_to_the_next_period_beginning(given_day)
    desired_wday = Date.parse(ENV['fab_starting_day']).wday
    current_date_progress = given_day

    until current_date_progress.wday == desired_wday do
      current_date_progress = current_date_progress.advance days: 1
    end

    current_date_progress
  end

  private

    # This method controls whether the old fab or the slightly fresher fab is
    # displayed on /users.  It's determined by the day, and doesn't have
    # hour/minute resolution because it turns over on friday (generally the day
    # to start doing FAB on).
    # Old fab refers to a FAB which was created 2 mondays ago, not the most
    # recent monday.
    # If it's mon, tuesday, wed, thrs, then jump back 2 mondays
    # else if it's fri, sat, sun, mon, jump back 1 single monday
    def self.within_edit_period_of_old_fab?
      week_of_days = [0,1,2,3,4,5,6]

      starting_day_of_week = Date.parse(ENV['fab_starting_day']).wday

      # we need to rotate the week so it begins with the day of the week after
      # the fab period.  This allows us to easily see that the first half of
      # the rotated array refers to days that we need to jump
      # backward by 2 mondays instead of just the nearest one Monday
      rotated_week = week_of_days.rotate(week_of_days.find_index(starting_day_of_week) + 1) # rotate 2 if Monday

      jump_back_two_monday_days = rotated_week[0...3]
      # jump_back_single_monday_days = rotated_week[4..-1]

      if jump_back_two_monday_days.include?(DateTime.now.in_time_zone.wday)
        true
      else
        false
      end
    end

    def display_start_day_of_week(p_start)
      ist_of_month = p_start.strftime("%e").to_i.ordinalize
      p_start.strftime("Week of %B #{ist_of_month}, %Y")
    end

end
