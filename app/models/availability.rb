class Availability < ActiveRecord::Base
  belongs_to :place
  
  validates_presence_of [:availability_type, :date_start, :date_end], :message => "101"
  validates_presence_of [:date_start, :date_end], :message => "101"
  validates_numericality_of :availability_type, :message => "118"
  validates_numericality_of :price_per_night, :allow_nil => true, :message => "118"
  
  validates_date :date_start, :after => :today,      :after_message => "119"
  validates_date :date_end,   :after => :date_start, :after_message => "120"

  validate :validates_overlapping

  # Checks if any other interval for the same place, overlaps this interval
  def validates_overlapping
    # Type = Price change
    if self['availability_type'] == 2
      # Checks if the object is already stored in db or not
      if self['id']
        list = Availability.where(["id <> ? AND place_id = ? AND availability_type = 2", self['id'], place_id]).all
      else
        list = Availability.where(["place_id = ? AND availability_type = 2", place_id]).all
      end
      
      list.each {|foo|
        if (self['date_start'] - foo['date_end']) * (foo['date_start'] - self['date_end']) >= 0
            errors.add(:message, '121')
        end
      }
    end
  end
end