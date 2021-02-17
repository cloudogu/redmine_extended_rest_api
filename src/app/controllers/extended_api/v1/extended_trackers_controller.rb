module ExtendedApi
  module V1
    class ExtendedTrackersController < ExtendedApplicationController
      accept_api_auth :create, :show, :update, :destroy

      def show
        render json: Tracker.sorted
      end

      def create
        if params.nil? || params.empty?
          render status: :bad_request, json: { errors: ["no tracker data provided"] }
        else
          @tracker = Tracker.new
          @tracker.safe_attributes = params
          if @tracker.save
            # workflow copy
            if !params[:copy_workflow_from].blank? && (copy_from = Tracker.find_by_id(params[:copy_workflow_from]))
              @tracker.copy_workflow_rules(copy_from)
            end
            render json: {}, status: :created
          else
            render json: { errors: @tracker.errors }, status: :bad_request
          end
        end
      end

      def update
        if params.nil? || params[:id].nil?
          render status: :bad_request, json: { errors: ["no tracker data provided"] }
        else
          @tracker = Tracker.find(params[:id])
          @tracker.safe_attributes = params
          if @tracker.save
            render json: @tracker
          else
            render status: :bad_request, json: { errors: @tracker.errors }
          end
        end
      end

      def destroy
        @tracker = Tracker.find(params[:id])
        begin
          if @tracker.destroy
            render json: @tracker
          else
            render status: :bad_request, json: { errors: @tracker.errors }
          end
        rescue StandardError => e
          # we need to catch the error otherwise it would lead to an unhandled server error
          render status: :bad_request, json: { errors: [e.message] }
        end
      end
    end
  end
end