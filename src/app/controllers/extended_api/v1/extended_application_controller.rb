module ExtendedApi
  module V1
    class ExtendedApplicationController < ApplicationController
      # @return [TrueClass, FalseClass]
      def require_login
        unless User.current.logged?
          respond_to do |format|
            format.any {
              if Setting.rest_api_enabled? && accept_api_auth?
                head(:unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"')
              else
                head(:forbidden)
              end
            }
          end
          return false
        end
        true
      end
    end
  end
end