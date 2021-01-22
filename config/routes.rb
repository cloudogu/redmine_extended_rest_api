# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match 'custom_api/settings', :controller => 'extended_settings', :action => 'create', :via => [:post]
match 'custom_api/settings', :controller => 'extended_settings', :action => 'show', :via => [:get]