class Team < ActiveRecord::Base

  has_many :users

  default_scope { order(weight: :asc) }

end
