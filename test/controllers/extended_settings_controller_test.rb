require File.expand_path('../../test_helper', __FILE__)

class ExtendedSettingsControllerTest < ActionController::TestCase
  fixtures :settings
  fixtures :users

  def test_show_unauth
    authHeader = { :Authorization => "Basic YWRtaW46YWRtaW1=" }
    request.headers.merge! authHeader
    contentTypeHeader = { "Content-Type" => "application/json" }
    request.headers.merge! contentTypeHeader
    acceptHeader = { "Accept" => "application/json" }
    request.headers.merge! acceptHeader

    get :show

    assert_response :unauthorized
  end

  def test_show
    authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
    request.headers.merge! authHeader

    get :show

    assert_response :success, @response.body
    settings = @response.json_body["settings"]
    assert_contains settings, "app_title", "Megamine"
  end

  def test_create
    authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
    request.headers.merge! authHeader
    contentTypeHeader = { "Content-Type" => "application/json" }
    request.headers.merge! contentTypeHeader

    json = { settings: { app_title: "Minimine" }}.to_json
    post :create, body: json

    assert_response :no_content

    get :show

    assert_response :success, @response.body
    settings = @response.json_body["settings"]
    assert_contains settings, "app_title", "Minimine"
  end

  def test_create_unauth
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

  def test_create_error_on_invalid_body
    authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
    request.headers.merge! authHeader
    contentTypeHeader = { "Content-Type" => "application/json" }
    request.headers.merge! contentTypeHeader

    json = { bla: { invalid: "megatrue" } }.to_json
    post :create, body: json

    parsed_response = @response.json_body
    assert_response 400
    assert_equal "no settings provided", parsed_response['errors']
  end

  def test_create_error_on_invalid_setting
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
