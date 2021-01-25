class ExtendedSettingsController < ApplicationController
  include Swagger::Docs::Methods

  swagger_controller :posts, 'Post Controller'
  swagger_api :create do
    summary 'Adds or updates the given settings'
    notes 'Should be used for creating and updating settings'
    param :form, 'post[name]', :string, :required, 'name'
    param :form, 'post[publish]', :boolean, :required, 'publish'
  end
  swagger_api :show do
    summary 'Get all the posts'
    notes 'Should be used for fetching a post'
    param :path, :id, :string, :id
    response :unauthorized
    response :ok, "Success"
  end

  before_action :require_login
  skip_before_action :verify_authenticity_token
  accept_api_auth :create, :show

  def show
    render :json => { settings: Setting.all }
  end

  def create
    if params[:settings].nil?
      render :json => { result: "fail", errors: "no settings provided", settings: Setting.all }
    else
      errors = Setting.set_all_from_params(params[:settings].to_unsafe_hash)
      if errors.blank?
        render :json => { result: "success", errors: nil, settings: Setting.all }
      else
        render :json => { result: "fail", errors: errors, settings: Setting.all }
      end
    end
  end
end
