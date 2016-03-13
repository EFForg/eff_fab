class Team < ActiveRecord::Base
  has_many :users

  default_scope { order(weight: :asc) }

  before_save { |t| t.name = t.name.downcase }
end
