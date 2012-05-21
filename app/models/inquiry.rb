class Inquiry < ActiveRecord::Base
  belongs_to :user
  belongs_to :place
  has_one :conversation, :as => :target

  serialize :extra

  validates_presence_of :user, :place

  attr_accessor :message

  # Include the Rakismet model
  include Rakismet::Model

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

    # Creates a new conversation around the inquiry
    inquiry.start_conversation(params[:message])

    # Set the content for the rakismet to check for spam
    # TODO: May need to set the other params too as per https://github.com/joshfrench/rakismet
    self.rakismet_attrs(:content => params[:message])

    # Sends notification
    InquiryMailer.inquiry_confirmed_renter(inquiry).deliver

    # Check if this inquiry is spam?
    if inquiry.spam?
      InquiryMailer.inquiry_spam(inquiry).deliver
    else
      InquiryMailer.inquiry_confirmed_owner(inquiry).deliver
    end

    inquiry
  end

  def self.without_reply(since = nil)
    conversations = Conversation.select('conversations.id, conversations.target_id, count(messages.id) replies').joins(:messages)
      .where(:target_type => 'Inquiry')
      .group('conversations.id').having('replies <= 1')
    if since
      conversations = conversations.where(['conversations.created_at > ?', since])
    end

    inquiry_ids = conversations.collect(&:target_id)
    Inquiry.where(:id => inquiry_ids)
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
    self.message = message
    # Check if there is a previous inquiry
    prev_inquiry = Inquiry.where(:user_id => self.user.id, :place_id => self.place.id).first
    if prev_inquiry && prev_inquiry.conversation
      conversation = prev_inquiry.conversation
      Messenger.add_reply(self.user, conversation.id, Message.new(:body => message),true)
    else
      conversation = Conversation.new
      conversation.recipient = self.place.user
      conversation.body = message
      conversation.target = self

      Messenger.start_conversation(self.user, conversation)
    end
  end

  # For empty messages about this inquiry
  def add_default_message
    self.transaction.add_system_message(:send)
  end

  def transaction
    t = Transaction.where(:inquiry_id => self.id).first
    unless t
      t = Transaction.create(
        :inquiry_id => self.id,
        :place_id => self.place_id,
        :user_id => self.user_id,
        :check_in => self.check_in,
        :check_out => self.check_out
      )
    end
    t
  end

  def conversation
    Conversation.find_by_target(self)
  end

  def recipient
    self.place.user if self.place
  end

  def send_reminder
    InquiryMailer.inquiry_reminder_owner(self).deliver
  end
end
