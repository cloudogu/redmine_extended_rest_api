# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

namespace :extended_api do
  namespace :v1 do
    get 'custom_fields', action: :show, controller: 'extended_custom_fields'
    get 'custom_fields/fieldtypes', action: :field_types, controller: 'extended_custom_fields'
    get 'custom_fields/fieldformats', action: :field_formats, controller: 'extended_custom_fields'
    post 'custom_fields', action: :create, controller: 'extended_custom_fields'
    patch 'custom_fields', action: :update, controller: 'extended_custom_fields'
    delete 'custom_fields', action: :destroy, controller: 'extended_custom_fields'

    get 'enumerations', action: :show, controller: 'extended_enumerations'
    get 'enumerations/enumtypes', action: :enum_types, controller: 'extended_enumerations'
    get 'enumerations/:type/customfields', action: :custom_fields, controller: 'extended_enumerations'
    post 'enumerations', action: :create, controller: 'extended_enumerations'
    patch 'enumerations', action: :update, controller: 'extended_enumerations'
    delete 'enumerations', action: :destroy, controller: 'extended_enumerations'

    get 'issue_statuses', action: :show, controller: 'extended_issue_statuses'
    post 'issue_statuses', action: :create, controller: 'extended_issue_statuses'
    patch 'issue_statuses', action: :update, controller: 'extended_issue_statuses'
    delete 'issue_statuses', action: :destroy, controller: 'extended_issue_statuses'

    get 'roles', action: :show, controller: 'extended_roles'
    get 'roles(/:id)/permissions', action: :perms, controller: 'extended_roles'
    post 'roles', action: :create, controller: 'extended_roles'
    patch 'roles(/:id)', action: :update, controller: 'extended_roles'
    delete 'roles(/:id)', action: :destroy, controller: 'extended_roles'

    get 'settings', action: :show, controller: 'extended_settings'
    put 'settings', action: :update, controller: 'extended_settings'

    get 'spec', to: redirect('plugin_assets/redmine_extended_rest_api/openapi.yml')

    get 'trackers', action: :show, controller: 'extended_trackers'
    post 'trackers', action: :create, controller: 'extended_trackers'
    patch 'trackers', action: :update, controller: 'extended_trackers'
    delete 'trackers', action: :destroy, controller: 'extended_trackers'

    get 'workflows', action: :show, controller: 'extended_workflows'
    patch 'workflows', action: :update, controller: 'extended_workflows'
  end
end
