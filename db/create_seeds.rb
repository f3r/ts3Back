# TODO: It doesn't shows state-less countries like Singapore :(
require 'mysql2'
@client = Mysql2::Client.new(:host => "localhost", :database => "heypal_development", :username => "root", :password => "root")

def country_search(country)
  puts "*"*40 + "\n"
  puts " Starting with country: #{country}"
  puts "*"*40 + "\n\n"
  query = "SELECT 
    foo1.id, 
    foo1.geo_ansiname as name, 
    foo1.geo_latitude as lat, 
    foo1.geo_longitude as lon,
    foo3.geo_ansiname as state,
    foo2.name as country,
    foo2.code_iso as country_code

   FROM cities as foo1

   JOIN countries as foo2
      ON foo1.geo_country_code = foo2.code_iso 

      JOIN states as foo3
      ON foo1.geo_admin1_code = foo3.geo_admin1_code
      AND foo2.code_iso = foo3.geo_country_code

   WHERE foo1.geo_country_code IN (\"#{country}\")
   GROUP BY foo1.id,foo2.code_iso
   ORDER BY foo1.geo_country_code, foo3.geo_ansiname, foo1.geo_ansiname;"
  results = @client.query(query)
  f = File.new("seeds.rb", "a")
  results.each { |r|
   f.write "City.create(name: \"#{r['name']}\", lat: #{r['lat']}, lon: #{r['lon']}, state: \"#{r['state']}\", country: \"#{r['country']}\", country_code: \"#{r['country_code']}\" )\n"
  }
  f.close
end

country_search("SG")
country_search("PH")
country_search("MY")
country_search("ID")
country_search("TH")
country_search("AU")
country_search("CN")
country_search("HK")
country_search("IN")
country_search("MO")
country_search("VN")