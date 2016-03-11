class Fab < ActiveRecord::Base
  has_attached_file :gif_tag,
    styles: { medium: "300x300>", thumb: "100x100>" },
    default_url: "/images/:style/missing.png"

  validates_attachment_content_type :gif_tag, content_type: /\Aimage\/.*\Z/

  default_scope { order('created_at DESC') }

  belongs_to :user
  has_many :notes
  has_many :forward, -> { where(forward: true) }, class_name: "Note"
  has_many :backward, -> { where(forward: false) }, class_name: "Note"


  accepts_nested_attributes_for :notes, reject_if: :all_blank, :allow_destroy => true

  after_initialize :setup_children

  def self.find_or_build_this_periods_fab
    start = get_start_of_current_fab_period
    fab_attrs = {period: start..start + 7.days}
    self.where(fab_attrs).first || self.new(period: start)
  end

  def self.get_start_of_current_fab_period
    p_start = (DateTime.now - DateTime.now.wday + 1).midnight
  end

  def setup_children
    if notes.empty?
      3.times { notes.build(forward: true) }
      3.times { notes.build(forward: false) }
    end
  end

  # This method presents to the view what period this FAB is for
  # Returns something like "February 8, 2016 - February 12, 2016"
  def display_back_time_span
    display_time_span(period)
  end

  def display_forward_time_span
    display_time_span(period + 1.week)
  end

  def previous_fab
    current_period = self.period
    self.user.fabs.where('period < ?', current_period).first
  end

  def next_fab
    current_period = self.period
    self.user.fabs.where('period > ?', current_period).last
  end

  # returns an array of two, indicating true or false whether there's a previos
  # or next fab relative to the fab_id supplied
  def which_neighbor_fabs_exist?
    [!self.previous_fab.nil?, !self.next_fab.nil?]
  end

  private

    def display_time_span(p_start)
      p_end = p_start + 4.days
      s = p_start.strftime("'%y: %b %e - ")
      s += p_end.strftime("%b %e")
      s
    end

end
