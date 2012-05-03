ActiveAdmin.register Transaction do
  
  menu :priority => 8
  actions :index , :show
  config.sort_order = 'id_desc'  

  scope :all, :default => true
  
  controller do
    helper 'admin/transactions'
    def scoped_collection
      Transaction.unscoped
    end
  end
  
  filter :user_id
  filter :state


  index :title => "Transaction" do
    id_column
    column :user, :sortable => :user_id
    column :state
    column :created_at
    column("Log")     {|transaction| transaction_links_column(transaction) }
  end
  
  
  show do |transaction|
     attributes_table do
      row("Id") {transaction.id }
      row :user
      row :place
      row :state
      row("Created Date") {transaction.created_at }
      panel "Log" do
      if transaction.transaction_logs.count > 0
      table_for(transaction.transaction_logs) do |t|
              t.column("State")          {|transaction_logs| "#{transaction_logs.state}" }
              t.column("Previous State") {|transaction_logs| "#{transaction_logs.previous_state}"}
              t.column("Created Date")   {|transaction_logs| "#{transaction_logs.created_at}"}
              t.column("Updated Date")   {|transaction_logs| "#{transaction_logs.updated_at}"}
            
        end
        else
              "Empty" 
       end
      end
    end
  end
end
