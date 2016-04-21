class Note < ActiveRecord::Base
  belongs_to :fab, touch: true

  default_scope { order('id') }
end
