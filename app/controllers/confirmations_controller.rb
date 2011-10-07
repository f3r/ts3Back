class ConfirmationsController < Devise::ConfirmationsController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # ==Resource URL
  # /users/confirmation.format
  # ==Example
  # POST https://backend-heypal.heroku.com/users/confirmation.json email=user@example.com
  # === Parameters
  # [:email]
  def create
    self.resource = resource_class.send_confirmation_instructions({:email => params[:email]})
    respond_with do |format|
      if successful_and_sane?(resource)
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "ok", :msg => I18n.t("devise.confirmations.send_instructions") },request.format.to_sym) }
      else
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "fail", :err => resource.errors },request.format.to_sym) }        
      end
    end
  end

  # ==Resource URL
  # /users/confirmation.format
  # ==Example
  # GET https://backend-heypal.heroku.com/users/confirmation.json confirmation_token=confirmation_token
  # === Parameters
  # [:confirmation_token]
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    respond_with do |format|
      if resource.errors.empty?
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "ok", :user => { :authentication_token => resource.authentication_token }, :msg => I18n.t("devise.confirmations.confirmed") },request.format.to_sym) }
      else
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "fail", :err => resource.errors },request.format.to_sym) }
      end
    end
  end

end