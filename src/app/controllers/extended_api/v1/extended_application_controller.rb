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

      def render_error(arg)
        arg = {:message => arg} unless arg.is_a?(Hash)

        @message = arg[:message]
        @message = l(@message) if @message.is_a?(Symbol)
        @status = arg[:status] || 500
        render status: @status, json: { "errors": [ @message ] }
      end
    end
  end
end