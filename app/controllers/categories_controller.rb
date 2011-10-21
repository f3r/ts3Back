class CategoriesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  # TODO: protect everything but /list with admin token

  # TODO: Do we need this method?
  # ==Resource URL
  # /categories.format
  # ==Example
  # GET https://backend-heypal.heroku.com/categories.json
  # === Parameters
  # None
  def index
    @categories = Category.all
    respond_with do |format|
      response = @categories.count > 0 ? { :stat => "ok", :categories => @categories } : { :stat => "ok", :err => I18n.t("no_results") }
      format.any(:xml, :json) { render :status => 200, request.format.to_sym => format_response(response,request.format.to_sym) }
    end
  end

  # ==Resource URL
  # /categories/list.format
  # ==Example
  # GET https://backend-heypal.heroku.com/categories/list.json
  # === Parameters
  # None
  def list
    cat_list = Rails.cache.fetch("category/list") { Category.category_tree }
    respond_with do |format|
      response =  { :stat => "ok", :categories => cat_list }
      format.any(:xml, :json) { 
        render :status => 200, 
        request.format.to_sym => format_response(response,request.format.to_sym) }
    end
  end
  
  # ==Resource URL
  # /categories/:id.format
  # ==Example
  # GET https://backend-heypal.heroku.com/categories/id.json
  # === Parameters
  # [:id]  
  def show
    @category = Category.find(params[:id])
    respond_with do |format|
      format.any(:xml, :json) { 
        render :status => 200, 
        request.format.to_sym => format_response({ 
          :stat => "ok", 
          :category => @category },
          request.format.to_sym) }
    end
  end

  # ==Resource URL
  # /categories.format
  # ==Example
  # POST https://backend-heypal.heroku.com/categories.json access_token=access_token&name=name&parent_id=parent_id
  # === Parameters
  # [:access_token]
  # [:name]
  # [:parent_id]
  def create
    check_token
    parent = Category.find(params[:parent_id]) if params[:parent_id]
    new_category = { :name => params[:name] }
    new_category.merge!({:parent => parent}) if parent
    @category = Category.new(new_category)
    respond_with do |format|
      if @category.save
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :category => @category },
          request.format.to_sym)}
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(@category.errors.messages) },
          request.format.to_sym)}
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
    check_token
    @category = Category.find(params[:id])
    respond_with do |format|
      if @category.update_attributes(:name => params[:name])
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :category => @category },
          request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(@category.errors.messages) },
          request.format.to_sym) }
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
    check_token
    @category = Category.find(params[:id])
    respond_with do |format|
      if @category.destroy
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "ok", 
            :category => @category },
          request.format.to_sym) }
      else
        format.any(:xml, :json) { 
          render :status => 200, 
          request.format.to_sym => format_response({ 
            :stat => "fail", 
            :err => format_errors(@category.errors.messages) },
          request.format.to_sym) }
      end
    end
  end
end