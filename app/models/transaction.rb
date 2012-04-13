require 'declarative_authorization/maintenance'
include Authorization::TestHelper
class Transaction < ActiveRecord::Base
  
  INACTIVE_STATES = [:cancelled, :auto_cancelled, :declined, :auto_declined]

  scope :active, where("state NOT IN (?)", INACTIVE_STATES)
  scope :inactive, where("state IN (?)", INACTIVE_STATES)
  
  belongs_to :user
  belongs_to :place
  has_many :transaction_logs, :dependent => :destroy
  has_one :availability, :dependent => :destroy
  serialize :additional_data
  
  before_create :set_transaction_code
  #after_create :add_inquiry_message # set_temporary_transaction_timeout

  validates_presence_of :check_in, :check_out, :user_id, :place_id, :state, :message => "101"
    # :currency, :price_per_night, :service_fee, :service_percentage, :sub_total    

  validates_date :check_in, :after => :today, :invalid_date_message => "113", :after_message => "119"
  validates_date :check_out, :after => :check_in, :invalid_date_message => "113", :after_message => "120"
  
  validate :check_min_max_stay

  include Workflow

  workflow_column :state

  workflow do

    state :bigbang do
      event :request, :transitions_to => :requested
    end
    state :requested do
      event :process_payment, :transitions_to => :processing_payment
      event :cancel,          :transitions_to => :cancelled
      event :auto_cancel,     :transitions_to => :auto_cancelled
    end
    state :processing_payment do
      event :cancel,          :transitions_to => :cancelled
      event :confirm_payment, :transitions_to => :confirmed_payment
    end
    state :confirmed_payment do
      event :decline,         :transitions_to => :declined
      event :confirm_rental,  :transitions_to => :confirmed_rental
      event :auto_decline,    :transitions_to => :auto_declined
    end
    state :cancelled
    state :auto_cancelled
    state :declined
    state :auto_declined
    state :confirmed_rental do
      event :decline, :transitions_to => :declined
    end
  
    before_transition do |from, to, triggering_event, *event_args|
      # check user permissions
#      halt! unless check_transaction_permissions(triggering_event)
    end
  
    after_transition do |from, to, triggering_event, *event_args|  
      # log every transaction
      log_transaction(:from => from, :to => to, :triggering_event => triggering_event, :additional_data => event_args[0])

      # Fake payment approval
      if triggering_event == :process_payment
        self.confirm_payment!
      end
    end
    
  end

  def decline
    # delete availability if transaction was confirmed
    self.availability.destroy if self.confirmed_rental?
    # notify user, do refund
  end

  def auto_decline
    # notify user, do refund
  end
  
  def process_payment
    # do something
  end

  def confirm_payment
    # TODO: notify agent

    # Unconfirmed transactions expire in 24 hours
    unconfirmed_transaction_timeout = Time.now + UNCONFIRMED_TRANSACTION_TIMEOUT.day
    Delayed::Job.enqueue PurgeUnconfirmedTransactionJob.new(self.id), 0, unconfirmed_transaction_timeout
  end
  
  def confirm_rental
    availability = self.place.availabilities.create(
      :availability_type => 3,
      :date_start => self.check_in,
      :date_end => self.check_out,
      :comment => "Rented",
      :transaction => self
    )
    # auto decline other transactions
    self.place.auto_decline_transactions(check_in, check_out)
    # TODO: notify user
  end

  def self.purge_unpaid_transaction(transaction_id)
    without_access_control do
      transaction = Transaction.find(transaction_id)
      if transaction && transaction.requested?
        transaction.auto_cancel!
      end
    end
  end

  def self.purge_unconfirmed_transaction(transaction_id)
    without_access_control do
      transaction = Transaction.find(transaction_id)
      if transaction && transaction.confirmed_payment?
        transaction.auto_decline!
      end
    end
  end
  
  private
  
  def check_transaction_permissions(to)
    permitted_to?(to) or Authorization.current_user.has_role?("superadmin")
  end

  def generate_transaction_code
    # date + 4 random characters, 1 679 616 posible codes per day.
    transaction_code = Time.now.strftime("%y-%m%d-#{rand(36**4).to_s(36).upcase}")
    transaction = Transaction.find_by_transaction_code(transaction_code)
    if transaction
      self.generate_transaction_code
    else
      transaction_code
    end
  end

  def set_transaction_code
    self.transaction_code = generate_transaction_code
  end
  
  def set_temporary_transaction_timeout
    # Unpaid transactions expiration
    unpaid_transaction_timeout = Time.now + TRANSACTION_TIMEOUT.minutes
    Delayed::Job.enqueue PurgeUnpaidTransactionJob.new(self.id), 0, unpaid_transaction_timeout
  end

  def log_transaction(options={})
    begin
      log = self.transaction_logs.create(
        :state => options[:to], 
        :previous_state => options[:from], 
        :additional_data => options[:additional_data]
      )
      log.save
    rescue Exception => e
      logger.error { "Error [transaction.rb/transaction_log] #{e.message}" }
    end
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