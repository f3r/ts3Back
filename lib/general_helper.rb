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
      codes = error[1].map {|x|
        x = 103 if x == "is invalid" # horrible hack, used to catch the reset password validation error.
        x.to_i if (Float(x) or Integer(x)) rescue nil
      }.compact
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
    
    for field in fields
      if field == :avatar_file_name
        style = options[:style] if options[:style] rescue :large
        avatar = object.avatar.url(style) if object.avatar.url(style) != "none"
        filtered_object.merge!({:avatar => avatar })
      else
        filtered_object.merge!({field => object["#{field}"]})
      end
      if !additional_fields.blank? && additional_fields[field].class == Array
        filtered_object.merge!(get_additional_fields(field, object, additional_fields[field]))
        # remove_fields << field
      end
    end
    remove_fields.map{|x| filtered_object.delete(x) }
    return filtered_object
  end

  # used to filter any additional paramaters sent that doesn't match the allowed fields
  def filter_params(params, fields, options={})
    new_params = {}
    fields.map{|param| new_params.merge!(param => params[param]) if params.has_key?(param) && param != :id }
    return new_params
  end
  
  def get_additional_fields(field, object, fields)
    {field.to_sym => filter_fields(object.send(field),fields) }
  end

end