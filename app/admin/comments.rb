ActiveAdmin.register Comment, :as => "Question" do
  menu :priority => 5
  actions :all, :except => :new
  
  filter :comment
  
  index do
    id_column
    column :place
    column 'Question', :comment
    column :user
    column :created_at
    default_actions
  end
  
  show do |question|
    attributes_table do
      row :id    
      row :place
      row("QUESTION") {question.comment}
      row :user      
      row :created_at
    end
  end
  
  form do |f|
    f.inputs do
      f.input :id, :input_html => { :disabled => true }
      f.input :place, :input_html => { :disabled => true } 
      f.input :comment, :label => "Question"
      f.input :user, :input_html => { :disabled => true }
      f.input :created_at, :input_html => { :disabled => true } 
    end
    f.buttons
  end
  
end
