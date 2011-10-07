class ConfirmationsController < Devise::ConfirmationsController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # ==Resource URL
  # /users/confirmation.format
  # ==Example
  # POST http://backend-heypal.heroku.com/users/confirmation.json email=user@example.com
  # === Parameters
  # [:email]
  def create
    resource = resource_class.find_by_email(params[:email])
    respond_with do |format|
      if resource && !resource.confirmed?
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "ok", :user => { :id => resource.id, :confirmation_token => resource.confirmation_token } },request.format.to_sym) }
      elsif resource && resource.confirmed?
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "fail", :err => I18n.t("errors.messages.already_confirmed") },request.format.to_sym) }
      else
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "fail", :err => I18n.t("errors.messages.not_found") },request.format.to_sym) }        
      end
    end
  end

  # ==Resource URL
  # /users/confirmation.format
  # ==Example
  # GET http://backend-heypal.heroku.com/users/confirmation.json confirmation_token=confirmation_token
  # === Parameters
  # [:confirmation_token]
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    respond_with do |format|
      if resource.errors.empty?
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "ok", :user => { :id => resource.id }, :msg => I18n.t("devise.confirmations.confirmed") },request.format.to_sym) }
      else
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "fail", :err => resource.errors },request.format.to_sym) }
      end
    end
  end

end