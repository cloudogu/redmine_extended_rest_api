require File.expand_path('../../../../test_helper', __FILE__)
module ExtendedApi
  module V1
    class ExtendedSettingsControllerTest < ActionController::TestCase
      fixtures :settings
      fixtures :users

      test "check for correct route generation" do
        assert_routing({ method: :get, path: 'extended_api/v1/settings' }, { controller: "extended_api/v1/extended_settings", action: "show" })
        assert_routing({ method: :post, path: 'extended_api/v1/settings' }, { controller: "extended_api/v1/extended_settings", action: "create" })
      end

      test "show responds with unauthorized" do
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW1=" }
        request.headers.merge! authHeader
        contentTypeHeader = { "Content-Type" => "application/json" }
        request.headers.merge! contentTypeHeader
        acceptHeader = { "Accept" => "application/json" }
        request.headers.merge! acceptHeader

        get :show

        assert_response :unauthorized
      end

      test "show returns a list of available settings" do
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
        request.headers.merge! authHeader

        get :show

        assert_response :success, @response.body
        settings = @response.json_body["settings"]
        assert_contains settings, "app_title", "Megamine"
      end

      test "create updates the app_title setting" do
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
        request.headers.merge! authHeader
        contentTypeHeader = { "Content-Type" => "application/json" }
        request.headers.merge! contentTypeHeader

        json = { settings: { app_title: "Minimine" } }.to_json
        post :create, body: json

        assert_response :no_content

        get :show

        assert_response :success, @response.body
        settings = @response.json_body["settings"]
        assert_contains settings, "app_title", "Minimine"
      end

      test "create responds with unauthorized" do
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW1=" }
        request.headers.merge! authHeader
        contentTypeHeader = { "Content-Type" => "application/json" }
        request.headers.merge! contentTypeHeader
        acceptHeader = { "Accept" => "application/json" }
        request.headers.merge! acceptHeader

        json = {}.to_json
        post :create, body: json

        assert_response :unauthorized
      end

      test "create fails if no settings were provided" do
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
        request.headers.merge! authHeader
        contentTypeHeader = { "Content-Type" => "application/json" }
        request.headers.merge! contentTypeHeader

        json = { bla: { invalid: "megatrue" } }.to_json
        post :create, body: json

        parsed_response = @response.json_body
        assert_response :bad_request
        assert_equal "no settings provided", parsed_response['errors']
      end

      test "create fails with validation error" do
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
        request.headers.merge! authHeader
        contentTypeHeader = { "Content-Type" => "application/json" }
        request.headers.merge! contentTypeHeader

        json = { settings: { mail_from: "wrong-mail-address" } }.to_json
        post :create, body: json

        parsed_response = @response.json_body
        assert_response 400

        assert_equal [["mail_from", "ist nicht gültig"]], parsed_response['errors']
      end
    end
  end
end
