module ExtendedApi
  module V1
    class ExtendedEnumerationsController < ExtendedApplicationController
      before_action :require_login
      skip_before_action :verify_authenticity_token
      accept_api_auth :show

      def show
        @klass = Enumeration.get_subclass(params[:type])
        if @klass
          render json: @klass.shared.sorted
        else
          render json: Enumeration.shared.sorted
        end
      end
    end
  end
end