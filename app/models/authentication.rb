class Authentication < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :provider, :scope => :user_id, :message => "100"
  validates_presence_of :user_id, :provider, :uid, :token, :message => "101"
end
