require File.expand_path('../../../../test_helper', __FILE__)

class ExtendedApi::V1::ExtendedSettingsControllerTest < ActionController::TestCase
  fixtures :settings
  fixtures :users

  content_type_header = { 'Content-Type' => 'application/json' }
  auth_header_wrong = { :Authorization => 'Basic YWRtaW46YWRtaW1=' }
  auth_header = { :Authorization => 'Basic YWRtaW46YWRtaW4=' }

  test 'check for correct route generation' do
    assert_routing({ method: :get, path: 'extended_api/v1/settings' }, { controller: 'extended_api/v1/extended_settings', action: 'show' })
    assert_routing({ method: :put, path: 'extended_api/v1/settings' }, { controller: 'extended_api/v1/extended_settings', action: 'update' })
  end

  test 'show responds with 401 on unauthorized access' do
    request.headers.merge! auth_header_wrong
    request.headers.merge! content_type_header

    get :show

    assert_response :unauthorized
  end

  test 'show returns a list of available settings' do
    request.headers.merge! auth_header

    get :show

    assert_response :success, @response.body
    settings = @response.json_body
    assert_contains settings, 'app_title', 'Megamine'
  end

  test 'update updates the app_title setting' do
    request.headers.merge! auth_header
    request.headers.merge! content_type_header

    json = { app_title: 'Minimine' }.to_json
    put :update, body: json

    assert_response :no_content

    get :show

    assert_response :success, @response.body
    settings = @response.json_body
    assert_contains settings, 'app_title', 'Minimine'
  end

  test 'update responds with unauthorized' do
    request.headers.merge! auth_header_wrong
    request.headers.merge! content_type_header

    json = {}.to_json
    put :update, body: json

    assert_response :unauthorized
  end

  test 'update fails with validation error' do
    request.headers.merge! auth_header
    request.headers.merge! content_type_header

    json = { mail_from: 'wrong-mail-address' }.to_json
    put :update, body: json

    parsed_response = @response.json_body
    assert_response 400

    assert_equal [['mail_from', 'ist nicht gültig']], parsed_response['errors']
  end
end
