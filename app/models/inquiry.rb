class Inquiry < ActiveRecord::Base
  belongs_to :user
  belongs_to :place

  serialize :extra

  validates_presence_of :user, :place

  def self.create_and_notify(place, user, params)
    inquiry = self.new(
      :place => place,
      :user => user,
      :extra => params[:extra]
    )
    inquiry.check_in = params[:date_start]
    inquiry.length = [params[:length_stay], params[:length_stay_type]]

    return false unless inquiry.save

    # Sends notification
    InquiryMailer.inquiry_confirmed_renter(place, params).deliver
    InquiryMailer.inquiry_confirmed_owner(place, params, inquiry.check_in, inquiry.check_out, user).deliver
    InquiryMailer.inquiry_confirmed_admin(place, params, inquiry.check_in, inquiry.check_out, user, inquiry).deliver

    # Creates a new conversation around the inquiry
    inquiry.start_conversation(params[:message])

    inquiry
  end

  def length=(a_length)
    self.length_stay, self.length_stay_type = a_length

    return unless self.check_in && self.length_stay && self.length_stay_type

    case self.length_stay_type.to_sym
    when :days
      self.check_out = self.check_in + self.length_stay.days
    when :weeks
      self.check_out = self.check_in + self.length_stay.weeks
    when :months
      self.check_out = self.check_in + self.length_stay.months
    end
  end

  def start_conversation(message)
    conversation = Conversation.new
    conversation = Conversation.new
    conversation.recipient = self.place.user
    conversation.body = message
    conversation.target = self

    Messenger.start_conversation(self.user, conversation)
  end
end
