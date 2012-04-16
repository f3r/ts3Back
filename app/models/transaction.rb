require 'declarative_authorization/maintenance'
class Transaction < ActiveRecord::Base
  include Workflow
  include Authorization::TestHelper

  belongs_to :user
  belongs_to :place
  has_many :transaction_logs, :dependent => :destroy
  #has_one :availability, :dependent => :destroy

  before_create :set_transaction_code
  #after_create :add_inquiry_message

  validates_presence_of :check_in, :check_out, :user_id, :place_id, :state, :message => "101"

  validates_date :check_in, :after => :today, :invalid_date_message => "113", :after_message => "119"
  validates_date :check_out, :after => :check_in, :invalid_date_message => "113", :after_message => "120"

  validate :check_min_max_stay

  workflow_column :state

  workflow do

    state :initial do
      event :request, :transitions_to => :requested
    end
    state :requested do
      event :pre_approve,     :transitions_to => :ready_to_pay
      event :decline,         :transitions_to => :declined
    end
    state :ready_to_pay do
      event :cancel,          :transitions_to => :cancelled
      event :pay,             :transitions_to => :paid
    end
    state :paid
    state :cancelled
    #state :auto_cancelled
    state :declined

    before_transition do |from, to, triggering_event, *event_args|
      # check user permissions
      halt! unless permitted_to?(triggering_event)
    end

    after_transition do |from, to, triggering_event, *event_args|
      # log every transaction
      log_transaction(:from => from, :to => to, :triggering_event => triggering_event, :additional_data => event_args[0])
    end
  end

  def change_state!(event)
    events = self.current_state.events.keys
    if events.include?(event.to_sym)
      self.send("#{event}!")
    end
  end

  private

  def generate_transaction_code
    # date + 4 random characters, 1 679 616 posible codes per day.
    transaction_code = Time.now.strftime("%y-%m%d-#{rand(36**4).to_s(36).upcase}")

    if Transaction.exists?(:transaction_code => transaction_code)
      self.generate_transaction_code
    else
      transaction_code
    end
  end

  def set_transaction_code
    self.transaction_code = generate_transaction_code
  end

  def log_transaction(options={})
    log = self.transaction_logs.create(
      :state => options[:to],
      :previous_state => options[:from],
      :additional_data => options[:additional_data]
    )
    log.save
  end

  def check_min_max_stay
    check_in = self.check_in.to_date
    check_out = self.check_out.to_date
    total_days = (check_in..check_out).to_a.count

    if self.place && !self.place.stay_unit.blank?
      min_stay = self.place.minimum_stay.send(self.place.stay_unit)
      max_stay = self.place.maximum_stay.send(self.place.stay_unit)
      days = total_days.days

      unless days >= min_stay or min_stay == 0
        errors.add(:check_out, "141") # minimum stay not met
      end

      unless days <= max_stay or max_stay == 0
        errors.add(:check_out, "142") # over maximum stay
      end

    end

  end

  # def add_inquiry_message
  #   inquiry = self.user.inquiries.where(:place_id => self.place_id).first
  #   conversation = Conversation.where(:target_id => inquiry.id).first
  #   Messenger.add_reply(self.user, conversation.id, Message.new(:body => "transaction_confirmed_rental"))
  # end
end