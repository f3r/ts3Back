object false
node(:stat) { 'ok' }
child @conversation do
  attributes :id
  attribute :created_at => :date
  child :sender => :from do
    attributes :id, :email, :first_name, :last_name
    node(:avatar) {|u| u.avatar.url(:thumb) if u.avatar? }
  end
  child :target => :inquiry do
    node(:place_title) {|i| i.place.title }
    node(:place_thumb) {|i| i.place.primary_photo.photo.url(:small) }
    node(:length) {|i| i.length_in_words }
    attribute :guests
    node(:check_in) {|i| I18n.l(i.check_in, :format => :human) }
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