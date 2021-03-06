module ExtendedApi
  module V1
    class ExtendedSettingsController < ExtendedApplicationController
      accept_api_auth :update, :show

      def show
        render json: Setting.all
      end

      def update
        if params.nil? || params.empty?
          render status: :bad_request, json: { errors: 'no settings provided' }
        else
          errors = Setting.set_all_from_params(params.to_unsafe_hash)
          if errors.blank?
            render json: {}, status: :no_content
          else
            render json: { errors: errors }, status: :bad_request
          end
        end
      end
    end
  end
end
