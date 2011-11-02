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
    if options[:additional_fields]
      additional_fields = options[:additional_fields]
      additional_fields.each_pair{ |field,v| fields << field.to_sym }
    end
    filtered_object = {}
    remove_fields = []

    logger.error { "OBJECT = #{object.to_yaml}" }
    logger.error { "FIELDS = #{fields.to_yaml}" }
    
    for field in fields
      if field == :avatar_file_name
        style = options[:style] if options[:style] rescue :large
        avatar = object.avatar.url(style) if object.avatar.url(style) != "none"
        filtered_object.merge!({:avatar => avatar })
      elsif field == :amenities
        filtered_object.merge!({field => object.group_attributes(additional_fields[field], field.to_s)})
      elsif field == :location
        filtered_object.merge!({field => object.group_attributes(additional_fields[field])})
        additional_fields[field].map{|x| remove_fields << x }
      elsif field == :reviews
        filtered_object.merge!({field => object.group_attributes(additional_fields[field], field.to_s)})
        additional_fields[field].map{|x| remove_fields << "#{field.to_s}_#{x}".to_sym }
      elsif field == :terms_of_offer
        filtered_object.merge!({field => object.group_attributes(additional_fields[field])})
        additional_fields[field].map{|x| remove_fields << x }
      elsif field == :pricing
        filtered_object.merge!({field => object.group_attributes(additional_fields[field])})
        additional_fields[field].map{|x| remove_fields << x }
      elsif field == :details
        filtered_object.merge!({field => object.group_attributes(additional_fields[field])})
        additional_fields[field].map{|x| remove_fields << x }
      elsif field == :user
        filtered_object.merge!({field => filter_object(object.user,additional_fields[field]).group_attributes(additional_fields[field] << :avatar)})
      elsif field == :place_type
        filtered_object.merge!({field => filter_object(object.place_type,additional_fields[field]).group_attributes(additional_fields[field])})
      elsif field == :state
        filtered_object.merge!({field => filter_object(object.state,additional_fields[field]).group_attributes(additional_fields[field])})
      elsif (field == :country) and (object.class.to_s != "Address")
        filtered_object.merge!({field => filter_object(object.country,additional_fields[field]).group_attributes(additional_fields[field])})
      else
        filtered_object.merge!({field => object["#{field}"]})
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