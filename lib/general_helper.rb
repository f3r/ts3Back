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
    logger.error { "object: #{object.first_name.to_s}" }
    logger.error { "fields: #{fields.to_s}" }
    if !options[:additional_fields].nil?
      options[:additional_fields].each_pair{ |field,v| fields << field.to_sym }
    end
    filtered_object = {}
    remove_fields = []
    for field in fields
      if field == :avatar_file_name
        style = options[:style] if options[:style] rescue :large
        avatar = object.avatar.url(style) if object.avatar.url(style) != "none"
        filtered_object = filtered_object.merge({:avatar => avatar })
      elsif field == :amenities
        filtered_object = filtered_object.merge({field => object.group_attributes(options[:additional_fields][:amenities], "amenities")})
      elsif field == :location
        filtered_object = filtered_object.merge({field => object.group_attributes(options[:additional_fields][:location])})
        options[:additional_fields][:location].map{|x| remove_fields << x }
      elsif field == :reviews
        filtered_object = filtered_object.merge({field => object.group_attributes(options[:additional_fields][:reviews], "reviews")})
        options[:additional_fields][:reviews].map{|x| remove_fields << "reviews_#{x}".to_sym }
      else
        filtered_object = filtered_object.merge({field => object["#{field}"]})
      end
    end
    remove_fields.map{|x| filtered_object.delete(x) }
    return filtered_object
  end
  
  def filter_params(params, fields, options={})
    new_params = {}
    fields.map{|param| new_params.merge!(param => params[param]) if params.has_key?(param) && param != :id }
    return new_params
  end

  def group_attributes(attributes, prefix = nil)
    attributes_array = {}
    if prefix
      attributes.map{|attribute| attributes_array.merge!(attribute => self["#{prefix}_#{attribute.to_s}"]) if self["#{prefix}_#{attribute.to_s}"]}
    else
      attributes.map{|attribute| attributes_array.merge!(attribute => self[attribute]) if self[attribute]}
    end
    return attributes_array    
  end

end