class Fab < ActiveRecord::Base
  has_attached_file :gif_tag,
    styles: { medium: "300x300>", thumb: "100x100>" },
    default_url: "/images/:style/missing.png"

  validates_attachment_content_type :gif_tag, content_type: /\Aimage\/.*\Z/

  belongs_to :user
  has_many :notes

  accepts_nested_attributes_for :notes, reject_if: :all_blank, :allow_destroy => true

  after_initialize :setup_children

  def self.find_or_build_this_periods_fab
    fab_attrs = {period: get_start_date_of_current_fab_period}
    self.where(fab_attrs).first || self.new(fab_attrs)
  end

  def self.get_start_date_of_current_fab_period
    p_start = (DateTime.now - DateTime.now.wday + 1)
  end

  def setup_children
    if notes.empty?
      3.times { notes.build(forward: true)}
      3.times { notes.build(forward: false)}
    end
  end

  def forward
    n = notes.where(forward: true)
    n = notes.select {|n| n.forward} if n.empty?
    n
  end

  def backward
    n = notes.where(forward: false)
    n = notes.select {|n| !n.forward} if n.empty?
    n
  end

  def period
    # FIXME: this method is a stub

    # FIXME: this method needs to be changed into a database column
    # this stub is returning the previous monday as a DateTime object
    p_start = (DateTime.now - DateTime.now.wday + 1)
  end


  # def present_period
  #   p_start = period
  #
  #   p_end = p_start + 4.days
  #   s = p_start.strftime("%B %e, %Y - ")
  #   s += p_end.strftime("%B %e, %Y")
  #   s
  # end

  # This method presents to the view what period this FAB is for
  # Returns something like "February 8, 2016 - February 12, 2016"
  def display_back_time_span
    display_time_span(period)
  end

  def display_forward_time_span
    display_time_span(period + 1.week)
  end


  private

    def display_time_span(p_start)
      p_end = p_start + 4.days
      s = p_start.strftime("%B %e, %Y - ")
      s += p_end.strftime("%B %e, %Y")
      s
    end


end
