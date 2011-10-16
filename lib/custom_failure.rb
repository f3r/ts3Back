class CustomFailure < Devise::FailureApp

  protected

  def i18n_message(default = nil)
    message = warden.message || warden_options[:message] || default || :unauthenticated
    if message.is_a?(Symbol)
      case
        when message == :unconfirmed then {:user => 107}
        when message == :unauthenticated then {:user => 108}
        when message == :invalid then {:user => 109}
        else message
      end
    else
      message.to_s
    end
  end

  def http_auth_body
    return i18n_message unless request_format
    method = "to_#{request_format}"
    if method == "to_xml"
      { :stat => "fail", :err => i18n_message }.to_xml(:root => "rsp")
    elsif {}.respond_to?(method)
      { :stat => "fail", :err => i18n_message }.send(method)
    else
      i18n_message
    end
  end

end