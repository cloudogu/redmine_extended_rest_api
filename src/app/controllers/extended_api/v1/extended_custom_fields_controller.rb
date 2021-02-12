module ExtendedApi
  module V1
    class ExtendedCustomFieldsController < ExtendedApplicationController
      before_action :require_login
      skip_before_action :verify_authenticity_token
      accept_api_auth :create, :update, :destroy

      def create
        render json: {}
      end

      def update
        render json: {}
      end

      def destroy
        render json: {}
      end
    end
  end
end