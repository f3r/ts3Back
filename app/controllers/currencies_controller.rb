class CurrenciesController < ApiController
  filter_access_to :all, :attribute_check => false
  respond_to :xml, :json

  # == Description
  # Returns a list of all the currencies 
  # ==Resource URL
  # /currencies.format
  # ==Example
  # GET https://backend-heypal.heroku.com/currencies.json active=1
  # === Parameters
  # [active]
  # === Error codes
  # [115] No results
  def get_currencies
    @fields = [:id, :symbol, :currency_code, :active , :currency_abbreviation]
    if params[:active]
      @currencies = Rails.cache.fetch('currencies_all_active') { 
        Currency.active.select(@fields).all
      }
    else
      @currencies = Rails.cache.fetch('currencies_cities_all') { 
        Currency.select(@fields).all
      }
    end
    if @currencies && !@currencies.blank?
      return_message(200, :ok, {:currencies => filter_fields(@currencies,@fields)})
    elsif @currencies && @currencies.blank?
      return_message(200, :ok, {:err => {:currencies => [115]}})
    else
      return_message(200, :fail, {:err => {:currencies => [101]}})
    end
  end

end