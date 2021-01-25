require File.expand_path('../../test_helper', __FILE__)

class ExtendedSettingsControllerTest < ActionController::TestCase
  fixtures :settings
  fixtures :users

  # Replace this with your real tests.
  def test_show
    headers = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
    request.headers.merge! headers
    get :show
    assert_response :success, @response.body
  end

  def test_create
    authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
    request.headers.merge! authHeader
    contentTypeHeader = { "Content-Type" => "application/json" }
    request.headers.merge! contentTypeHeader

    json = { settings: { app_title: "Minimine" }}.to_json
    post :create, body: json

    parsed_response = @response.json_body
    settings = parsed_response["settings"]
    assert_equal "success", parsed_response['result']
    assert_contains settings, "app_title", "Minimine"
  end
end
