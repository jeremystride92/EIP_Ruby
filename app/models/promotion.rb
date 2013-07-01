class Promotion < ActiveRecord::Base
  belongs_to :venue

  validates :title, presence: true
  validates :venue, presence: true
end
