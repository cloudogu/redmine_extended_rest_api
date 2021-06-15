Redmine::Plugin.register :redmine_extended_rest_api do
  name 'Extended rest api plugin'
  author 'Christian Beyer (Cloudogu GmbH)'
  author_url 'https://cloudogu.com'
  description 'This plugin extends the existing rest api with new endpoints to manage Redmine.'
  version '1.1.0'

  settings default: {}
end
