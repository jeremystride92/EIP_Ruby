class CardTheme < ActiveRecord::Base
  belongs_to :venue
  attr_accessible :landscape_background, :name, :portrait_background
end
