class SessionsController < Devise::SessionsController

  skip_before_filter :verify_authenticity_token

  # POST /users/sign_in
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    respond_to do |format|
      if sign_in(resource_name, resource)
        format.any(*navigational_formats) { redirect_to after_sign_in_path_for(resource) }
        format.json { render :json => { :success => true } }
        format.xml { render :xml => { :success => true } }
      end
    end
  end

  # DELETE /users/sign_out
  def destroy
    signed_in = signed_in?(resource_name)
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :signed_out if signed_in
    respond_to do |format|
      format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name) }
      format.json { render :json => { :success => true } }
      format.xml { render :xml => { :success => true } }
    end
  end

end