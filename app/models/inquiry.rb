class Inquiry < ActiveRecord::Base
  belongs_to :user
  belongs_to :place

  serialize :extra

  validates_presence_of :user, :place

  attr_accessor :message

  def self.create_and_notify(place, user, params)
    inquiry = self.new(
      :place => place,
      :user => user,
      :extra => params[:extra],
      :guests => params[:guests]
    )
    inquiry.check_in = params[:date_start]
    inquiry.length = [params[:length_stay], params[:length_stay_type]]

    return false unless inquiry.save

    # Sends notification
    InquiryMailer.inquiry_confirmed_renter(inquiry).deliver
    InquiryMailer.inquiry_confirmed_owner(inquiry).deliver
    InquiryMailer.inquiry_confirmed_admin(place, params, inquiry.check_in, inquiry.check_out, user, inquiry).deliver

    # Creates a new conversation around the inquiry
    inquiry.start_conversation(params[:message])

    inquiry
  end

  def length=(a_length)
    if a_length[0] =~ /more/i
      a_length[0] = -1 # Special value
    end
    self.length_stay, self.length_stay_type = a_length

    return unless self.check_in && self.length_stay && self.length_stay_type

    if self.length_stay == -1
      self.check_out = nil
    else
      case self.length_stay_type.to_sym
      when :days
        length = self.length_stay.days
      when :weeks
        length = self.length_stay.weeks
      when :months
        length = self.length_stay.months
      else
        self.length_stay_type = nil
      end

      self.check_out = self.check_in + length if length
    end
  end

  def length_in_words
    return unless self.length_stay && self.length_stay_type
    if self.length_stay == 1
      "#{self.length_stay} #{self.length_stay_type.singularize}"
    else
      "#{self.length_stay} #{self.length_stay_type}"
    end
  end

  def start_conversation(message)
    conversation = Conversation.new
    conversation.recipient = self.place.user
    conversation.body = message
    self.message = message
    conversation.target = self

    Messenger.start_conversation(self.user, conversation)
  end

  # For empty messages about this inquiry
  def default_message
    'Inquiry sent'
  end
end
