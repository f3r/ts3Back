namespace :photos do
  desc "Regenerate image versions"
  task :regenerate => :environment do
    Photo.all.each do |record|
      puts "Regenerating: #{record.id}"
      begin
        record.photo.reprocess!
      rescue Exception => e
        puts e.inspect
      end
    end
  end
end