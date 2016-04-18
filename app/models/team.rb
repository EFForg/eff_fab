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
    # User.all.select { |u| u.upcoming_fab.id.nil? }
    target_period = Fab.get_start_of_current_fab_period
    p1 = target_period.strftime("%Y-%m-%d")
    p2 = (target_period + 1.day).strftime("%Y-%m-%d")

    # query_non_runners = <<-EOT.strip_heredoc
    #
    # SELECT "users"."name", "fabs"."period"
    # FROM "users"
    #   INNER JOIN "fabs"
    #   ON "fabs"."user_id" = "users"."id"
    #     WHERE "fabs"."period" BETWEEN date('#{p1}') AND date('#{p2}');
    #
    # EOT

    q = <<-EOT.strip_heredoc

    SELECT *
    FROM "users"
      INNER JOIN "fabs"
      ON "fabs"."user_id" = "users"."id"
      GROUP BY "users"."email"
        HAVING max(
          case
            WHEN "fabs"."period" BETWEEN date('#{p1}') AND date('#{p2}') THEN
              1
            ELSE
              0
            END
        ) = 0
    EOT

    User.find_by_sql(q)
  end

end
