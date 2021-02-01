# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match 'extended_api/v1/settings', :controller => 'extended_settings', :action => 'create', :via => [:post]
match 'extended_api/v1/settings', :controller => 'extended_settings', :action => 'show', :via => [:get]

match 'extended_api/v1/trackers', :controller => 'extended_trackers', :action => 'show', :via => [:get]
match 'extended_api/v1/trackers', :controller => 'extended_trackers', :action => 'create', :via => [:post]