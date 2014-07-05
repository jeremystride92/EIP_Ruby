class TextusCredential < ActiveRecord::Base
  belongs_to :venue

  validates :username, :api_key, presence: true
end