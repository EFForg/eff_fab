class Team < ActiveRecord::Base
  has_many :users

  default_scope { order(weight: :asc) }

  def self.all_including_runner_ups(eager_load = true)
    teams = if eager_load
      self.all.includes(users: { current_period_fab: [:notes, :forward, :backward] }).to_a
    else
      self.all.to_a
    end

    teams << self.runner_ups
  end

  def self.runner_ups
    Team.new(name: "Team Runner Up", weight: 200)
  end

  def self.get_runners
    User.all.select { |u| u.upcoming_fab.id.nil? }
  end

end
