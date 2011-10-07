class CustomFailure < Devise::FailureApp

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