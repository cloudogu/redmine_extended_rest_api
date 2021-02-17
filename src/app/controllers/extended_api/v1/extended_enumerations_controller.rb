module ExtendedApi
  module V1
    class ExtendedEnumerationsController < ExtendedApplicationController
      accept_api_auth :show, :create, :update, :destroy
      before_action :find_enumeration, :only => [:update, :destroy]

      def show
        @klass = Enumeration.get_subclass(params[:type])
        if @klass
          render json: @klass.shared.sorted
        else
          render json: Enumeration.shared.sorted
        end
      end

      def create
        render json: {}
      end

      def update
        render json: {}
      end

      def destroy
        if !@enumeration.in_use?
          # No associated objects
          @enumeration.destroy
          render json: @enumeration
        elsif params[:reassign_to_id].present? && (reassign_to = @enumeration.class.find_by_id(params[:reassign_to_id].to_i))
          @enumeration.destroy(reassign_to)
          render json: @enumeration
        else
          render json: { "errors": [ "cannot delete enumeration with id '#{params[:id]}' because it is in use" ] }, status: :bad_request
        end
      end

      private

      def find_enumeration
        @enumeration = Enumeration.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_404 message: "enumeration with id '#{params[:id]}' could not be found"
      end
    end
  end
end