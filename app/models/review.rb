class Review < ActiveRecord::Base
  using_access_control

  belongs_to :place
  belongs_to :user

  validates_presence_of [
    :user_id,
    :place_id,
    :comment
  ], :message => "101"
  
  validates_numericality_of :accuracy, :cleanliness, :checkin, :communication, :location, :value, :message => "118", :allow_nil => true
  validates_inclusion_of :accuracy, :cleanliness, :checkin, :communication, :location, :value, :in => 1..5, :message => "147", :allow_nil => true
  
  after_commit :update_averages
  
  private

  def update_averages
    reviews = [:accuracy, :cleanliness, :checkin, :communication, :location, :value]
    must_update = []
    for review in reviews
      must_update << review if self.send(review) && self.send(review) > 0
    end
    self.place.update_review_average(must_update) unless must_update.blank?
  end

end