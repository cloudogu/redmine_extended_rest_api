module ExtendedApi
  module V1
    class ExtendedCustomFieldsController < ExtendedApplicationController
      before_action :require_login
      skip_before_action :verify_authenticity_token
      accept_api_auth :show, :create, :update, :destroy

      def show
        render json: CustomField.all
      end

      def types
        render json: list_possible_types
      end

      def create
        if params[:type].nil? || params[:type].empty?
          render json: { "errors": ['no field type provided'] }
        else
          @custom_field = CustomField.new_subclass_instance(params[:type])
          unless @custom_field
            render json: { "errors": ["could not create field of type '#{params[:type]}'. possible values are '#{list_possible_types}'"] }, status: :bad_request
            return
          end
          begin
            @custom_field.safe_attributes = params
            if @custom_field.save
              render json: @custom_field, status: :created
            else
              render json: { "errors": [@custom_field.errors] }, status: :bad_request
            end
          rescue => e
            render json: { "errors": [e.message] }, status: :bad_request
          end
        end
      end

      def update
        if params[:id].nil?
          render json: { "errors": ['no id provided'] }, status: :bad_request
        else
          begin
            @custom_field = CustomField.find(params[:id])
          rescue ActiveRecord::RecordNotFound => e
            render status: :not_found, json: e.message
            return
          end
          @custom_field.safe_attributes = params
          if @custom_field.save
            render json: @custom_field
          else
            render json: { "errors": @custom_field.errors }, status: :bad_request
          end
        end
      end

      def destroy
        if params[:id].nil?
          render json: { "errors": ['no id provided'] }, status: :bad_request
        else
          begin
            @custom_field = CustomField.find(params[:id])
          rescue ActiveRecord::RecordNotFound => e
            render status: :not_found, json: { "errors": [e.message] }
            return
          end
          begin
            if @custom_field.destroy
              render json: @custom_field
            end
          rescue
            render json: { "errors": [l(:error_can_not_delete_custom_field)] }, status: :bad_request
          end
        end
      end

      private

      def list_possible_types
        CustomFieldsHelper::CUSTOM_FIELDS_TABS.map { |h| h[:name] }
      end
    end
  end
end