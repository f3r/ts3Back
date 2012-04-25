ActiveAdmin.register FrontCarrousel do
  menu :priority => 5

  filter :label
  
  index do
    id_column
    column :link
    column :label
    column('IMAGE') {|fc| image_tag(fc.photo.url('tiny'))}
    column :active
    column :created_at 
    default_actions
  end  
  show do |fc|
    attributes_table do
      row :id    
      row :link
      row :label
      row("IMAGE") do
         image_tag(fc.photo.url)
      end
      row :active 
      row :created_at
    end
  end  
  
  form do |f|
    f.inputs do
      f.input :link
      f.input :label
      f.input :photo
      f.input :active
    end
    f.buttons
  end  
  
end
