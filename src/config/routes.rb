# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

namespace :extended_api do
  namespace :v1 do
    get 'settings', action: :show, controller: 'extended_settings'
    post 'settings', action: :create, controller: 'extended_settings'

    get 'trackers', action: :show, controller: 'extended_trackers'
    post 'trackers', action: :create, controller: 'extended_trackers'
    patch 'trackers', action: :update, controller: 'extended_trackers'
    delete 'trackers', action: :destroy, controller: 'extended_trackers'

    get 'issue_statuses', action: :show, controller: 'extended_issue_statuses'
    post 'issue_statuses', action: :create, controller: 'extended_issue_statuses'
    patch 'issue_statuses', action: :update, controller: 'extended_issue_statuses'
    delete 'issue_statuses', action: :destroy, controller: 'extended_issue_statuses'

    get 'workflows', action: :show, controller: 'extended_workflows'
    patch 'workflows', action: :update, controller: 'extended_workflows'
  end
end
