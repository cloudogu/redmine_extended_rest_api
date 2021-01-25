Swagger::Docs::Config.register_apis({
    "1.0" => {
      # the extension used for the API
      :api_extension_type => :json,
      # the output location where your .json files are written to
      :api_file_path => "public/apidocs",
      # the URL base path to your API
      :base_path => "http://localhost:3000",
      # if you want to delete all .json files at each generation
      :clean_directory => true,
      # add custom attributes to api-docs
      :attributes => {
        :info => {
          "title" => "Your application title",
          "description" => "Rails API documention with Swagger UI.",
          "termsOfServiceUrl" => "",
          "contact" => ""
        }
      }
    }
  })
