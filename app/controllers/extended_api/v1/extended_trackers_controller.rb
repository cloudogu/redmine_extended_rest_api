module ExtendedApi
  module V1
    class ExtendedTrackersController < ApplicationController
      before_action :require_login
      skip_before_action :verify_authenticity_token
      accept_api_auth :create, :show, :update

      def show
        render :json => Tracker.sorted
      end

      def create
        if params[:tracker].nil?
          render :status => :bad_request, :json => { errors: "no tracker data provided" }
        else
          @tracker = Tracker.new
          @tracker.safe_attributes = params[:tracker]
          if @tracker.save
            # workflow copy
            if !params[:copy_workflow_from].blank? && (copy_from = Tracker.find_by_id(params[:copy_workflow_from]))
              @tracker.copy_workflow_rules(copy_from)
            end
            render :json => {}, :status => :created
          else
            render :json => { errors: @tracker.errors }, :status => :bad_request
          end
        end
      end

      def update
        if params[:tracker].nil? || params[:id].nil?
          render :status => :bad_request, :json => { errors: "no tracker data provided" }
        else
          @tracker = Tracker.find(params[:id])
          @tracker.safe_attributes = params[:tracker]
          if @tracker.save
            render :json => { tracker: @tracker }
          else
            render :status => :bad_request, :json => { errors: @tracker.errors }
          end
        end
      end
    end
  end
end