module FrontendHelper
  def frontend_url(path)
    FRONTEND_PATH + path
  end

  def seo_place_path(place)
    result = place[:title].dup
    result.gsub!(/[^\x00-\x7F]+/, '') # Remove anything non-ASCII entirely (e.g. diacritics).
    result.gsub!(/[^\w_ \-]+/i, '')   # Remove unwanted chars.
    result.gsub!(/[ \-]+/i, '-')      # No more than one of the separator in a row.
    result.gsub!(/^\-|\-$/i, '')      # Remove leading/trailing separator.
    result.downcase!
    city = Rails.cache.fetch('geo_cities_' + place[:city_id].to_s) { 
      City.find(place[:city_id])
    }
    "#{FRONTEND_PATH}/#{city[:name].parameterize('_')}/#{place[:id]}-#{result}"
  end

  def site_name
    SiteConfig.site_name
  end

  def support_email
    mail_to SiteConfig.support_email
  end
end