module GeneralHelper

  def format_response(response,format)
    method = "to_#{format}"
    if method == "to_xml"
      response.to_xml(:root => "rsp", :dasherize => false)
    else
      response.send(method)
    end
  end
  
  def format_errors(errors)
    error_list = {}
    for error in errors
      codes = error[1].map {|x| x.to_i if (Float(x) or Integer(x)) rescue nil }.compact
      error_list = error_list.merge({error[0] => codes})
    end
    return error_list
  end

  def delete_caches(caches)
    for cache in caches
      Rails.cache.delete(cache)
    end
  end

  def filter_fields(object, fields, options={})
    if object.class == Array or object.class == ActiveRecord::Relation
      array = []
      object.map{|new_object| array << filter_object(new_object, fields, options) }
      return array
    else
      return filter_object(object, fields, options)
    end
  end

  def filter_object(object, fields, options={})
    filtered_object = {}
    for field in fields
      if field == :avatar_file_name
        style = options[:style] if options[:style] rescue :large
        avatar = object.avatar.url(style) if object.avatar.url(style) != "none"
        filtered_object = filtered_object.merge({:avatar => avatar })
      else
        filtered_object = filtered_object.merge({field => object["#{field}"]})
      end
    end
    return filtered_object
  end

end