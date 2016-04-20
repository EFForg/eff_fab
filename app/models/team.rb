class Team < ActiveRecord::Base
  has_many :users

  default_scope { order(weight: :asc) }

  def self.all_including_runner_ups(eager_load = true)
    teams = if eager_load
      self.all.includes(users: { current_period_fab: [:forward, :backward] })
    else
      self.all
    end

    teams << self.runner_ups
  end

  def self.runner_ups
    Team.new(name: "Team Runner Up", weight: 200)
  end

  def self.get_runners(target_period = Fab.get_start_of_current_fab_period)
    # target_period = Fab.get_start_of_current_fab_period # if target_period.nil?

    p1 = target_period.strftime("%Y-%m-%d")
    p2 = (target_period + 1.day).strftime("%Y-%m-%d")

    # Note, you can flip those bits in the case to invert the function
    q = <<-EOT.strip_heredoc

      SELECT users.id, users.name
      FROM users
        LEFT JOIN fabs
        ON fabs.user_id = users.id
        GROUP BY users.id
          HAVING max(
            case
              WHEN fabs.period BETWEEN date('#{p1}') AND date('#{p2}') THEN
                1
              ELSE
                0
              END
          ) = 0

    EOT

    runners = User.find_by_sql(q)
  end

end
