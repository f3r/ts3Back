#coding: utf-8
class MigrateCarrousels < ActiveRecord::Migration
  def up
    fc = FrontCarrousel.new({link: "http://www.squarestays.com/singapore/5-the-clift-prime-location-loft-with-view", label: "The Clift - an elegant Singapore downtown loft", position: 1, active: 1})
    fc.photo = File.open("#{Rails.root}/db/migrate/existingcarrouselimages/one.jpg")
    fc.save!
    
    fc = FrontCarrousel.new({link: "http://www.squarestays.com/singapore/2-cavenagh-lodge-central-great-for-family", label: "Cavenagh - perfect for families coming to Singapore", position: 2, active: 1})
    fc.photo = File.open("#{Rails.root}/db/migrate/existingcarrouselimages/two.jpg")
    fc.save!

    fc = FrontCarrousel.new({link: "http://www.squarestays.com/kuala_lumpur", label: "Kuala Lumpur - now featured on SquareStays!", position: 3, active: 1})
    fc.photo = File.open("#{Rails.root}/db/migrate/existingcarrouselimages/three.jpg")
    fc.save!
    
    fc = FrontCarrousel.new({link: "/city-guides/singapore", label: "Singapore - a rising global business powerhouse", position: 4, active: 1})
    fc.photo = File.open("#{Rails.root}/db/migrate/existingcarrouselimages/four.jpg")
    fc.save!

    fc = FrontCarrousel.new({link: "/city-guides/hong-kong", label: "Hong Kong - business gateway to China", position: 5, active: 1})
    fc.photo = File.open("#{Rails.root}/db/migrate/existingcarrouselimages/five.jpg")
    fc.save!
        
  end
end
