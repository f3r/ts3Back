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
    current_user = options[:current_user] if options[:current_user]
    filtered_object = {}
    remove_fields = []
    
    # change place currency if options[:currency] is valid
    if object.class == Place && options[:currency] && options[:currency] != object.currency && valid_currency?(options[:currency])
      new_currency = options[:currency]
      object.price_per_night = exchange_currency(object.price_per_night, object.currency, new_currency) unless object.price_per_night.blank?
      object.price_per_week = exchange_currency(object.price_per_week, object.currency, new_currency)  unless object.price_per_week.blank?
      object.price_per_month = exchange_currency(object.price_per_month, object.currency, new_currency) unless object.price_per_month.blank?
      object.price_final_cleanup = exchange_currency(object.price_final_cleanup, object.currency, new_currency) unless object.price_final_cleanup.blank?
      object.price_security_deposit = exchange_currency(object.price_security_deposit, object.currency, new_currency) unless object.price_security_deposit.blank?
      object.currency = new_currency
    end

    # change availability currency if options[:currency] is valid
    if object.class == Availability && options[:currency] && options[:currency] != object.place.currency && valid_currency?(options[:currency])
      new_currency = options[:currency]
      object.price_per_night = exchange_currency(object.price_per_night, object.place.currency, new_currency) unless object.price_per_night.blank?
    end
    
    for field in fields
      if field == :avatar_file_name
        if !object.avatar_file_name.blank?
          style = options[:style].blank? ? :thumb : options[:style]
          avatar = object.avatar.url(style) if object.avatar.url(style) != "none"
          filtered_object[:avatar] = avatar
        else
          filtered_object[:avatar] = nil
        end
      elsif field == :favorited
        filtered_object[:favorited] = current_user.favorite?(object.class, object.id) if current_user
      elsif field == :photos
        # I am going to hell because of this line
        filtered_object[:photos] = object.photos.as_json
      else
        filtered_object[field] = object["#{field}"]
      end
      if !additional_fields.blank? && additional_fields[field].class == Array
        filtered_object.merge!(get_additional_fields(field, object, additional_fields[field]))
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
    if !object.send("#{field.to_s}").nil?
      additional_object = Rails.cache.fetch("#{field.to_s}_#{object.send("#{field.to_s}_id")}") {
        Rails.logger.info "Cache: #{field.to_s}_#{object.send("#{field.to_s}_id")} miss"
        object.send("#{field.to_s}").class.find(object.send("#{field.to_s}_id"))
      }
      return {field.to_sym => filter_fields(additional_object,fields) }
    else
      return {}
    end
  end

  def valid_currency?(currency)
    begin
      Money.new(1000, currency).currency
      true
    rescue Exception => e
      false
    end
  end
  
  def exchange_currency(price, old_currency, new_currency)
  begin
    return unless price
    price.to_money(old_currency).exchange_to(new_currency).to_f    
  rescue Exception => e
    0
  end
  end

  # Validates multiple attributes using the validation rules from a model
  def validate_attributes(model, attributes)
    errors = {}
    attribute_list = attributes.map{|k,v| k}
    temp = model.new(attributes)
    if !temp.valid?
      temp.errors.each {|attribute,value|
        errors.merge!({attribute => temp.errors.get(attribute)}) if !temp.errors.get(attribute).blank? && attribute_list.include?(attribute)
      }
    end
    return errors
  end
  
end