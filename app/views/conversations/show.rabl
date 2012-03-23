object false
node(:stat) { 'ok' }
child @conversation do
  attributes :id
  attribute :created_at => :date
  child :sender => :from do
    attributes :id, :email, :first_name, :last_name
    node(:avatar) {|u| u.avatar.url(:thumb) if u.avatar? }
  end
end
child @messages => :messages do
  attributes :body
  attribute :created_at => :date
  child :from => :from do
    attributes :id, :email, :first_name, :last_name
    node(:avatar) {|u| u.avatar.url(:thumb) if u.avatar? }
  end
end