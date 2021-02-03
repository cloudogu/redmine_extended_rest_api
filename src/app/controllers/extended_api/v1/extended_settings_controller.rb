module ExtendedApi
  module V1
    class ExtendedSettingsController < ApplicationController
      before_action :require_login
      skip_before_action :verify_authenticity_token
      accept_api_auth :create, :show

      def show
        render :json => { settings: Setting.all }
      end

      def create
        if params[:settings].nil?
          render :status => :bad_request, :json => { errors: "no settings provided" }
        else
          errors = Setting.set_all_from_params(params[:settings].to_unsafe_hash)
          if errors.blank?
            render :json => {}, :status => :no_content
          else
            render :json => { errors: errors }, :status => :bad_request
          end
        end
      end
    end
  end
end
