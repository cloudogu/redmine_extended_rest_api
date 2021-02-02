# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

namespace :extended_api do
  namespace :v1 do
    get 'settings', action: :show, controller: 'extended_settings'
    post 'settings', action: :create, controller: 'extended_settings'

    patch 'trackers', action: :update, controller: 'extended_trackers'
    post 'trackers', action: :create, controller: 'extended_trackers'
    get 'trackers', action: :show, controller: 'extended_trackers'
  end
end