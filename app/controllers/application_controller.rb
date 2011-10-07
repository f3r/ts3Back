class ApplicationController < ActionController::Base
  # rescue_from ActionController::RoutingError, :with => :not_found
  protect_from_forgery

  def format_response(response,format)
    response = request.format == "xml" ? response.to_xml(:root => "rsp", :dasherize => false) : response
    return response
  end

  # private
  #   def not_found(exception = nil)
  #     if exception
  #         logger.info "Rendering 404: #{exception.message}"
  #     end
  #     render :status => 404, :json => {:error=>"not found"}, :layout => false
  #   end

end