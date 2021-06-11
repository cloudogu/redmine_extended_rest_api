module ExtendedApi
  module V1
    class ExtendedRolesController < ExtendedApplicationController
      accept_api_auth :create, :show, :update, :destroy, :perms

      before_action :find_role, :only => [:update, :destroy, :perms]
      before_action :check_body, :only => [:create, :update]

      def show
        render json: Role.sorted
      end

      def create
        if params.nil? || params.empty?
          render_400 message: "no role data provided"
        else
          @role = Role.new
          @role.safe_attributes = params
          if @role.save
            # workflow copy
            if !params[:copy_workflow_from].blank? && (copy_from = Role.find_by_id(params[:copy_workflow_from]))
              @role.copy_workflow_rules(copy_from)
            end
            render json: @role, status: :created
          else
            render_400 message: @role.errors
          end
        end
      end

      def perms
        setable = setable_permissions @role
        if params[:display] == "short"
          setable = setable.map { |role| role.name }
        end
        render json: setable
      end

      def update
        if params.nil? || params[:id].nil?
          render_400 message: "no role data provided"
        else

          @role.safe_attributes = params
          if @role.save
            render json: @role
          else
            render_400 message: @role.errors
          end
        end
      end

      def destroy
        begin
          render json: @role if @role.destroy
        rescue => e
          render_400 message: e.message
        end
      end

      private

      def find_role
        @role = Role.find(params[:id]) if params[:id]
      rescue ActiveRecord::RecordNotFound
        render_404 message: "role with id '#{params[:id]}' could not be found"
      end

      def setable_permissions(role = nil)
        setable_permissions = Redmine::AccessControl.permissions - Redmine::AccessControl.public_permissions
        if role
          if role.builtin == Role::BUILTIN_NON_MEMBER
            setable_permissions -= Redmine::AccessControl.members_only_permissions
          end
          if role.builtin == Role::BUILTIN_ANONYMOUS
            setable_permissions -= Redmine::AccessControl.loggedin_only_permissions
          end
        end
        setable_permissions
      end

      def check_body
        begin
          params.require(:name)
        rescue => e
          render_400 message: e.message
          return
        end
      end
    end
  end
end