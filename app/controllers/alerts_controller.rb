class AlertsController < ApiController
  before_filter :get_user

  def initialize
    @fields = [
      :id, :alert_type, :query, :schedule, :delivery_method, :search_code, :active
    ]
  end

  # == Description
  # Lists an users alertes
  # ==Resource URL
  #   /users/:user_id/alerts.format
  # ==Example
  #   GET https://backend-heypal.heroku.com/users/1/alerts.json access_token=access_token
  #   GET https://backend-heypal.heroku.com/users/me/alerts.json access_token=access_token
  # === Parameters
  # [access_token]  Access token
  def index
    alerts = @user.alerts
    if alerts.count > 0
      return_message(200, :ok, {:alerts => filter_fields(alerts, @fields)})
    else
      return_message(200, :ok, {:err => {:alerts => [115]}})
    end
  end

  # == Description
  # Gets alert
  # Used for sharing
  # ==Resource URL
  #   /users/:user_id/alerts/:id.format
  # ==Example
  #   GET https://backend-heypal.heroku.com/users/1/alerts/31.json
  #   GET https://backend-heypal.heroku.com/users/me/alerts/31.json
  # === Parameters
  # [code] Search code
  def show
    alert = @user.alerts.find(params[:id])
    return_message(200, :ok, {:alert => filter_fields(alert, @fields)})
  end

  # == Description
  # Gets query from a alert code
  # Used for sharing
  # ==Resource URL
  #   /alerts/:code.format
  # ==Example
  #   GET https://backend-heypal.heroku.com/alerts/abcdefghi.json
  # === Parameters
  # [code] Search code
  def get_params
    alert = Alert.unscoped.find_by_search_code(params[:code])
    if alert
      return_message(200, :ok, {:alert_type => alert.alert_type, :query => alert.query })
    else
      return_message(200, :ok, {:err => {:alert => [106]}})
    end
  end

  # == Description
  # Saves search parameters and creates an alert
  # ==Resource URL
  #   /users/:user_id/alerts.format
  # ==Example
  #   POST https://backend-heypal.heroku.com/users/1/alerts.json access_token=access_token
  #   POST https://backend-heypal.heroku.com/users/me/alerts.json access_token=access_token
  # === Parameters
  # [access_token]  Access token
  # [schedule] daily, weekly, monthly
  # [delivery_method] email, sms, email_sms
  # [query] hash containing search parameters  
  # == Errors
  # [101] can't be blank 
  # [103] is invalid
  def create
    search = filter_params(params, @fields)
    # search[:query]['results_ids'] = params['query']['results_ids'].split(" ") if !params['query']['results_ids'].blank?
    alert = @user.alerts.new(search)
    if alert.save
      return_message(200, :ok, {:alert => filter_fields(alert, @fields)})
    else
      return_message(200, :fail, {:err => format_errors(alert.errors.messages)})
    end
  end

  # == Description
  # Updates an alert
  # ==Resource URL
  # /users/:user_id/alerts/:id.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/users/341/alerts/1.json access_token=access_token
  # PUT https://backend-heypal.heroku.com/users/me/alerts/1.json access_token=access_token
  # === Parameters
  # [access_token]
  # [schedule] daily, weekly, monthly
  # [delivery_method] email, sms, email_sms
  # [query] hash containing search parameters  
  # == Errors
  # [101] can't be blank 
  # [103] is invalid
  def update
    alert = @user.alerts.find(params[:id])
    new_params = filter_params(params, @fields)
    # new_params[:query]['results_ids'] = params['query']['results_ids'].split(" ") if !params['query']['results_ids'].blank?
    if alert.update_attributes(new_params)
      return_message(200, :ok, {:alert => filter_fields(alert, @fields)})
    else
      return_message(200, :fail, {:err => format_errors(alert.errors.messages)})
    end
  end

  # == Description
  # Deletes an alert
  # ==Resource URL
  # /users/:user_id/alerts/:id.format
  # ==Example
  # DELETE https://backend-heypal.heroku.com/users/341/alerts/:id.json access_token=access_token
  # DELETE https://backend-heypal.heroku.com/users/me/alerts/:id.json access_token=access_token
  # === Parameters
  # [access_token]
  def destroy
    alert = @user.alerts.find(params[:id])
    if alert.soft_delete
      return_message(200, :ok)
    else
      return_message(200, :fail, {:err => format_errors(alert.errors.messages)})
    end
  end

  protected
  def get_user
    if params[:user_id] && params[:user_id].to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) != nil # is numeric
      id = params[:user_id]
    elsif params[:user_id] == "me" && current_user
      id = current_user.id
    end
    @user = User.find(id) if id
  end

end