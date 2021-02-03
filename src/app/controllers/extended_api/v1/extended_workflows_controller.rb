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
        find_trackers_roles_and_statuses_for_edit
        begin
          transitions = map_params(params)
          transitions.each do |_, transitions_by_new_status|
            transitions_by_new_status.each do |_, transition_by_rule|
              transition_by_rule.reject! {|_, transition| transition == 'no_change'}
            end
          end
          WorkflowTransition.replace_transitions(@trackers, @roles, transitions)
        rescue StandardError => e
          render json: { errors: e, message: e.message }, status: :bad_request
        end
        render json: {}, status: :no_content
      end

      private

      def map_params(request_params)
        mapped_params = Hash.new
        transitions = request_params[:transitions]
        transitions.each do |src_transition|
          source_status_position = find_entry_with_id(@statuses, src_transition['issue_status_id'])
          target_statuses = Hash.new
          src_transition[:transitions].each do |target_transition|
            target_status_position = find_entry_with_id(@statuses, target_transition['issue_status_id'])
            target_statuses[target_status_position.to_s] = get_types(target_transition['types'])
          end
          mapped_params[source_status_position.to_s] = target_statuses
        end
        mapped_params
      end

      def find_entry_with_id(collection, id)
        collection.each do |entry|
          return entry['position'] if entry['id'].to_s == id.to_s
        end
      end

      def get_types types
        type_hash = Hash.new
        types.each do |type|
          type_hash[type['name']] = type['value']
        end
        type_hash
      end

      def find_trackers_roles_and_statuses_for_edit
        find_roles
        find_trackers
        find_statuses
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

      def find_statuses
        @used_statuses_only = (params[:used_statuses_only] == '0' ? false : true)
        if @trackers && @used_statuses_only
          role_ids = Role.all.select(&:consider_workflow?).map(&:id)
          status_ids = WorkflowTransition.where(
            tracker_id: @trackers.map(&:id), role_id: role_ids
          ).distinct.pluck(:old_status_id, :new_status_id).flatten.uniq
          @statuses = IssueStatus.where(id: status_ids).sorted.to_a.presence
        end
        @statuses ||= IssueStatus.sorted.to_a
      end
    end
  end
end