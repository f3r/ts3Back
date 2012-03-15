class Favorite < ActiveRecord::Base
  belongs_to :favorable
  belongs_to :user

  validates :user_id, :presence => true, :uniqueness => {:scope => [:favorable_id, :favorable_type]}
  validates :favorable_id, :presence => true, :uniqueness => {:scope => [:user_id, :favorable_type]}
  validates :favorable_type, :presence => true, :uniqueness => {:scope => [:favorable_id, :user_id]}
end