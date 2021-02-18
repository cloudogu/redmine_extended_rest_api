module ExtendedApi
  module V1
    class ExtendedEnumerationsController < ExtendedApplicationController
      accept_api_auth :show, :create, :update, :destroy, :enum_types, :custom_fields
      before_action :find_enumeration, only: [:update, :destroy]
      before_action :build_new_enumeration, only: [:create, :custom_fields]

      def show
        @enumeration = Enumeration.get_subclass(params[:type])
        if @enumeration
          render json: @enumeration.shared.sorted
        elsif !params[:type]
          render_404 message: "could not find any enumeration with type '#{params[:type]}'"
        else
          render json: Enumeration.shared.sorted
        end
      end

      def enum_types
        render json: get_available_types_list
      end

      def custom_fields
        render json: get_available_custom_fields
      end

      def create
        if request.post? && @enumeration.save
          render json: @enumeration
        else
          render json: { "errors": [@enumeration.errors] }
        end
      end

      def update
        if @enumeration.update(enumeration_params)
          render json: @enumeration
        else
          render json: { "errors": [@enumeration.errors] }
        end
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
          render json: { "errors": ["cannot delete enumeration with id '#{params[:id]}' because it is in use"] }, status: :bad_request
        end
      end

      private

      def find_enumeration
        @enumeration = Enumeration.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_404 message: "enumeration with id '#{params[:id]}' could not be found"
      end

      def build_new_enumeration
        class_name = params[:enumeration] && params[:enumeration][:type] || params[:type]
        @enumeration = Enumeration.new_subclass_instance(class_name)
        if @enumeration
          @enumeration.attributes = enumeration_params || {}
        else
          render_400 message: "could not create enumeration with type '#{class_name}'. available types are: '#{get_available_types_list}'"
        end
      end

      def enumeration_params
        # can't require enumeration on #new action
        cf_ids = @enumeration.available_custom_fields.map {|c| c.multiple? ? {c.id.to_s => []} : c.id.to_s}
        params.permit(:name, :active, :is_default, :position, custom_field_values: cf_ids)
      end

      def get_available_types_list
        Enumeration.get_subclasses.map(&:to_s)
      end

      def get_available_custom_fields
        @enumeration.available_custom_fields.map {|cf|
          cf.multiple? ? {cf.id.to_s => []} : {
            "id": cf.id,
            "name": cf.name,
            "format": cf.field_format
          }}
      end
    end
  end
end