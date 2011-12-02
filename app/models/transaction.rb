class Transaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :place
  has_many :transaction_logs
  serialize :additional_data

  validates_date :check_in, :after => :today, :invalid_date_message => "113", :after_message => "119"
  validates_date :check_out, :after => :check_in, :invalid_date_message => "113", :after_message => "120"

  include Workflow

  workflow_column :state

  workflow do

    state :bigbang do
      event :request, :transitions_to => :requested
    end
  
    before_transition do |from, to, triggering_event, *event_args|
      halt! unless check_transaction_permissions(triggering_event)
    end
  
    after_transition do |from, to, triggering_event, *event_args|
      log_transaction(:from => from, :to => to, :triggering_event => triggering_event, :comment => event_args[0][:comment])
    end

  end
  
  private
  
  def check_transaction_permissions(to)
    permitted_to?(to) or Authorization.current_user.has_role?("superadmin")
  end
  
  def log_transaction(options={})
    begin
      log = self.transaction_logs.create(
        :user => Authorization.current_user, 
        :state => options[:to], 
        :previous_state => options[:from], 
        :data => {:comment => options[:comment]})
      log.save
    rescue Exception => e
      logger.error { "Error [transaction.rb/transaction_log] #{e.message}" }
    end
  end
  
end
