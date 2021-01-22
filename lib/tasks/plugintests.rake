desc "Print reminder about eating more fruit."
namespace :test do
  namespace :plugins do
    task :redmine_extended_rest_api do
      puts "Eat more apples!"
      Rails::TestUnit::Runner.rake_run FileList['plugins/redmine_extended_rest_api/**/*_test.rb']
    end
  end
end