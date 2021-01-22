class ExtendedSettingsController < ApplicationController

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
