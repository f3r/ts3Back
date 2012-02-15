namespace :photos do
  desc "Regenerate image versions"
  task :regenerate => :environment do
    Photo.all.each do |record|
      record.photo.recreate_versions!
    end
  end
end