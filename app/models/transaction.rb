require 'declarative_authorization/maintenance'
include Authorization::TestHelper
class Transaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :place
  has_many :transaction_logs, :dependent => :destroy
  serialize :additional_data
  
  before_create :set_transaction_code
  after_create :set_temporary_reservation

  validates_presence_of :check_in, :check_out, :user_id, :place_id, :state, 
    :currency, :price_per_night, :service_fee, :service_percentage, :sub_total, :message => "101"

  validates_date :check_in, :after => :today, :invalid_date_message => "113", :after_message => "119"
  validates_date :check_out, :after => :check_in, :invalid_date_message => "113", :after_message => "120"

  include Workflow

  workflow_column :state

  workflow do

    state :bigbang do
      event :request, :transitions_to => :requested
    end
    state :requested do
      event :reject, :transitions_to => :rejected
      event :accept, :transitions_to => :accepted
      event :auto_cancel, :transitions_to => :auto_cancelled
    end
    state :rejected do
      event :re_request, :transitions_to => :requested
    end
    state :accepted do
    end
    state :auto_cancelled do
    end
  
    before_transition do |from, to, triggering_event, *event_args|
      halt! unless check_transaction_permissions(triggering_event)
    end
  
    after_transition do |from, to, triggering_event, *event_args|
      log_transaction(:from => from, :to => to, :triggering_event => triggering_event, :additional_data => event_args[0])
    end

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

  def self.purge_temporary_reservation(transaction,availability)
    # TODO: check if transaction was paid before deleting it
    without_access_control do
      availability.destroy
      transaction.auto_cancel!
    end
  end

  private
  
  def check_transaction_permissions(to)
    permitted_to?(to) or Authorization.current_user.has_role?("superadmin")
  end

  def set_transaction_code
    self.transaction_code = self.generate_transaction_code
  end
  
  def set_temporary_reservation
    # add an temporary availability to give the user time to pay, etc. Expires in 5 minutes
    availability = self.place.availabilities.create(
      :availability_type => 3,
      :date_start => self.check_in,
      :date_end => self.check_out,
      :comment => "Expires at #{Time.now + 5.minutes}"
    )
    # create delayed job immediately
    # TODO: store this elsewhere, create site settings
    transaction_timeout = Time.now + 5.minutes
    Delayed::Job.enqueue PurgeTemporaryReservationJob.new(self, availability), 0, transaction_timeout
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
  
end