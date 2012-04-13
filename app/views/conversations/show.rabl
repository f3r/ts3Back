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
    attributes :id, :user_id
    node(:place_id)    {|i| i.place.id }
    node(:place_title) {|i| i.place.title }
    node(:place_thumb) {|i| i.place.primary_photo.photo.url(:medsmall) }
    node(:place_url)   {|i| seo_place_path(i.place) }
    node(:length)      {|i| i.length_in_words }
    node(:state)       {|i| i.transaction.state }
    attribute :guests
    node(:check_in) {|i| I18n.l(i.check_in, :format => :human) if i.check_in }
  end
end
child @messages => :messages do
  attributes :body, :system
  attribute :created_at => :date
  child :from => :from do
    attributes :id, :email, :first_name, :last_name
    node(:avatar) {|u| u.avatar.url(:thumb) if u.avatar? }
  end
end