module ExtendedApi
  module V1
    class ExtendedIssueStatusesController < ExtendedApplicationController
      accept_api_auth :create, :show, :update, :destroy

      def show
        render json: IssueStatus.sorted
      end

      def create
        if params.nil? || params.empty?
          render :status => :bad_request, :json => { errors: 'no issue status data provided' }
        else
          @issue_status = IssueStatus.new
          @issue_status.safe_attributes = params
          if @issue_status.save
            render json: {}, status: :created
          else
            render json: { errors: @issue_status.errors }, status: :bad_request
          end
        end
      end

      def update
        if params[:id].nil?
          render :status => :bad_request, :json => { errors: 'no issue status id provided' }
        elsif params.nil?
          render :status => :bad_request, :json => { errors: 'no issue status data provided' }
        else
          @issue_status = IssueStatus.find(params[:id])
          @issue_status.safe_attributes = params
          if @issue_status.save
            render :json => @issue_status
          else
            render :status => :bad_request, :json => { errors: @issue_status.errors }
          end
        end
      end

      def destroy
        @issue_status = IssueStatus.find(params[:id])
        begin
          if @issue_status.destroy
            render json: @issue_status
          else
            render status: :bad_request, json: { errors: @issue_status.errors }
          end
        rescue StandardError => e
          # we need to catch the error otherwise it would lead to an unhandled server error
          render status: :bad_request, json: { errors:  [l(:error_unable_delete_issue_status, ERB::Util.h(e.message))] }
        end
      end
    end
  end
end