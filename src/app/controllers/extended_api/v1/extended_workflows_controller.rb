module ExtendedApi
  module V1
    class ExtendedWorkflowsController < ApplicationController
      before_action :require_login
      skip_before_action :verify_authenticity_token
      accept_api_auth :show, :update

      def show
        begin
          render json: WorkflowTransition.all
        rescue StandardError => e
          render json: { errors: e, message: e.message }
        end
      end

      def update
        find_trackers_roles_for_edit
        begin
          transitions = params[:transitions]
          transitions.each do |_, transitions_by_new_status|
            transitions_by_new_status.each do |_, transition_by_rule|
              transition_by_rule.reject! { |_, transition| transition == 'no_change' }
            end
          end
          result = WorkflowTransition.replace_transitions(@trackers, @roles, transitions)
          render json: result
        rescue => e
          render json: { errors: [e.message] }, status: :bad_request
        end
      end

      private

      def find_trackers_roles_for_edit
        find_roles
        find_trackers
      end

      def find_roles
        ids = Array.wrap(params[:role_id])
        if ids == ['all']
          @roles = Role.sorted.select(&:consider_workflow?)
        elsif ids.present?
          @roles = Role.where(id: ids).to_a
        end
        @roles = nil if @roles.blank?
      end

      def find_trackers
        ids = Array.wrap(params[:tracker_id])
        if ids == ['all']
          @trackers = Tracker.sorted.to_a
        elsif ids.present?
          @trackers = Tracker.where(id: ids).to_a
        end
        @trackers = nil if @trackers.blank?
      end
    end
  end
end