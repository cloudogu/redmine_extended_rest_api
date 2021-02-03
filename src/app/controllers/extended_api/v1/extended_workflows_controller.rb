module ExtendedApi
  module V1
    class ExtendedWorkflowsController < ApplicationController
      before_action :require_login
      skip_before_action :verify_authenticity_token
      accept_api_auth :show

      def show
        begin
          render :json => WorkflowTransition.all
        rescue StandardError => e
          render :json => { errors: e, message: e.message }
        end
      end
    end
  end
end