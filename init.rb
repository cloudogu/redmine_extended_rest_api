Redmine::Plugin.register :redmine_extended_rest_api do
  name 'Extended rest api plugin'
  author 'Christian Beyer'
  author_url 'christian.beyer@cloudogu.com'
  description 'This plugin extends the existing rest api with new endpoints to manage Redmine.'
  version '1.0.0'

  settings :default => {
    'enabled' => false,
    'cas_url' => 'https://',
    'attributes_mapping' => 'firstname=first_name&lastname=last_name&mail=email',
    'autocreate_users' => false
  }, :partial => 'extended_settings/settings'

end
