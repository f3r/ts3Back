namespace :places do
  desc "Regenerate image versions"
  task :regenerate_photos => :environment do
    Photo.all.each do |record|
      puts "Regenerating: #{record.id}"
      begin
        record.photo.reprocess!
      rescue Exception => e
        puts e.inspect
      end
    end
  end

  desc "Recalculate usd prices"
  task :recalculate_prices => :environment do
    require 'declarative_authorization/maintenance'
    Authorization::Maintenance.without_access_control do
      Place.all.each do |place|
        #puts "Recalculating prices for place: #{place.id}"
        place.convert_prices_in_usd_cents!
      end
    end
  end
end