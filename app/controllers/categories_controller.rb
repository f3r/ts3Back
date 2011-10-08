class CategoriesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # ==Resource URL
  # /categories.format
  # ==Example
  # GET https://backend-heypal.heroku.com/categories.json access_token=access_token
  # === Parameters
  # [:access_token]
  def index
    raise Exceptions::UnauthorizedAccess unless authenticated?
    @categories = Category.all
    respond_with do |format|
      response = @categories.count > 0 ? { :stat => "ok", :categories => @categories } : { :stat => "ok", :err => I18n.t("no_results") }
      format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response(response,request.format.to_sym) }
    end
  end

  # ==Resource URL
  # /categories/:id.format
  # ==Example
  # GET https://backend-heypal.heroku.com/categories/id.json access_token=access_token
  # === Parameters
  # [:access_token]
  # [:id]  
  def show
    raise Exceptions::UnauthorizedAccess unless authenticated?
    @category = Category.find(params[:id])
    respond_with do |format|
      response = @category ? { :stat => "ok", :category => @category } : { :stat => "fail", :err => @category.errors }
      format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response(response,request.format.to_sym) }
    end
  end

  # ==Resource URL
  # /categories.format
  # ==Example
  # POST https://backend-heypal.heroku.com/categories.json access_token=access_token&name=name
  # === Parameters
  # [:access_token]
  # [:name]
  def create
    raise Exceptions::UnauthorizedAccess unless authenticated?
    @category = Category.new(:name => params[:name])
    respond_with do |format|
      if @category.save
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "ok", :category => @category, :msg => I18n.t("successfully_created", :object_name => t(@category.class.to_s.downcase), :name => @category.name) },request.format.to_sym) }
      else
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "fail", :err => @category.errors },request.format.to_sym) }
      end
    end
  end

  # ==Resource URL
  # /categories/:id.format
  # ==Example
  # PUT https://backend-heypal.heroku.com/categories/:id.json access_token=access_token&name=name
  # === Parameters
  # [:access_token]
  # [:name]
  def update
    raise Exceptions::UnauthorizedAccess unless authenticated?
    @category = Category.find(params[:id])
    respond_with do |format|
      if @category.update_attributes(:name => params[:name])
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "ok", :category => @category, :msg => I18n.t("successfully_updated", :object_name => t(@category.class.to_s.downcase), :name => @category.name) },request.format.to_sym) }
      else
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "fail", :err => @category.errors },request.format.to_sym) }
      end
    end
  end

  # ==Resource URL
  # /categories/:id.format
  # ==Example
  # DELETE https://backend-heypal.heroku.com/categories/:id.json access_token=access_token
  # === Parameters
  # [:access_token]
  def destroy
    raise Exceptions::UnauthorizedAccess unless authenticated?
    @category = Category.find(params[:id])
    respond_with do |format|
      if @category.destroy
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "ok", :category => @category, :msg => I18n.t("successfully_deleted", :object_name => t(@category.class.to_s.downcase), :name => @category.name) },request.format.to_sym) }
      else
        format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response({ :stat => "fail", :err => @category.errors },request.format.to_sym) }
      end
    end
  end

end