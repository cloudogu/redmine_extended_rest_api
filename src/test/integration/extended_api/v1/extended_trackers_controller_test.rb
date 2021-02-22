require File.expand_path('../../../../test_helper', __FILE__)

class ExtendedApi::V1::ExtendedTrackersControllerTest < ActionController::TestCase
  fixtures(
    :settings,
    :users,
    :trackers,
    :issue_statuses,
    :issues,
    :projects,
  )

  test 'check for correct route generation' do
    assert_routing({ method: :get, path: 'extended_api/v1/trackers' }, controller: 'extended_api/v1/extended_trackers', action: 'show')
    assert_routing({ method: :post, path: 'extended_api/v1/trackers' }, controller: 'extended_api/v1/extended_trackers', action: 'create')
    assert_routing({ method: :patch, path: 'extended_api/v1/trackers' }, controller: 'extended_api/v1/extended_trackers', action: 'update')
    assert_routing({ method: :delete, path: 'extended_api/v1/trackers' }, controller: 'extended_api/v1/extended_trackers', action: 'destroy')
  end

  test 'show responds with 401 on unauthorized access' do
    request.headers.merge! TestHeaders::AUTH_HEADER_WRONG
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    get :show

    assert_response :unauthorized
  end

  test 'create responds with 401 on unauthorized access' do
    request.headers.merge! TestHeaders::AUTH_HEADER_WRONG
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    post :create

    assert_response :unauthorized
  end

  test 'update responds with 401 on unauthorized access' do
    request.headers.merge! TestHeaders::AUTH_HEADER_WRONG
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    patch :update

    assert_response :unauthorized
  end

  test 'destroy responds with 401 on unauthorized access' do
    request.headers.merge! TestHeaders::AUTH_HEADER_WRONG
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    delete :destroy

    assert_response :unauthorized
  end

  test 'show responds with 403 if user is not an admin' do
    request.headers.merge! TestHeaders::AUTH_HEADER_USER
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    get :show

    assert_response :forbidden
    error = @response.json_body['errors']
    expected_error_message = ['Sie sind nicht berechtigt, auf diese Seite zuzugreifen.']
    assert_equal expected_error_message, error
  end

  test 'create responds with 403 if user is not an admin' do
    request.headers.merge! TestHeaders::AUTH_HEADER_USER
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    post :create

    assert_response :forbidden
    error = @response.json_body['errors']
    expected_error_message = ['Sie sind nicht berechtigt, auf diese Seite zuzugreifen.']
    assert_equal expected_error_message, error
  end

  test 'update responds with 403 if user is not an admin' do
    request.headers.merge! TestHeaders::AUTH_HEADER_USER
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    patch :update

    assert_response :forbidden
    error = @response.json_body['errors']
    expected_error_message = ['Sie sind nicht berechtigt, auf diese Seite zuzugreifen.']
    assert_equal expected_error_message, error
  end

  test 'destroy responds with 403 if user is not an admin' do
    request.headers.merge! TestHeaders::AUTH_HEADER_USER
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    delete :destroy

    assert_response :forbidden
    error = @response.json_body['errors']
    expected_error_message = ['Sie sind nicht berechtigt, auf diese Seite zuzugreifen.']
    assert_equal expected_error_message, error
  end

  test 'show responds with a list of trackers' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN

    get :show

    assert_response :success, @response.body
    trackers = @response.json_body
    contains_entry_with_value trackers, 'name', 'Feature request'
    assert_contains_entry trackers, 'name' => 'Feature request'
  end

  test 'create inserts a new tracker' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { name: 'megabug', "default_status_id": 55, "description": 'my description' }.to_json
    post :create, body: json

    assert_response :created
    tracker = @response.json_body
    assert_contains_entry [tracker], 'name' => 'megabug', 'description' => 'my description', 'default_status_id' => 55
  end

  test 'create fails if default status is missing' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { name: 'Megabug', "description": 'my description' } .to_json
    post :create, body: json

    parsed_response = @response.json_body
    assert_response :bad_request
    assert_equal ['muss ausgefüllt werden'], parsed_response['errors']['default_status']
  end

  test 'create fails if tracker already exists' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { name: 'Bug', "default_status_id": 55, "description": 'my description' }.to_json
    post :create, body: json

    parsed_response = @response.json_body
    assert_response :bad_request
    assert_equal ['ist bereits vergeben'], parsed_response['errors']['name']
  end

  test 'update updates the description' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { id: 4, "description": 'my description' }.to_json
    patch :update, body: json

    assert_response :success
    tracker = @response.json_body
    assert_contains_entry [tracker], 'id' => 4, 'name' => 'Bug Request', 'description' => 'my description', 'default_status_id' => 55

    get :show
    assert_response :success, @response.body
    trackers = @response.json_body
    assert_contains_entry trackers, 'id' => 4, 'name' => 'Bug Request', 'description' => 'my description', 'default_status_id' => 55
  end

  test 'destroy deletes a specific tracker' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { id: 5 }.to_json
    delete :destroy, body: json

    assert_response :success
    tracker_data = @response.json_body
    assert_contains_entry [tracker_data], 'id' => 5, 'default_status_id' => '55', 'name' => 'Delete Me!'

    get :show

    assert_response :success, @response.body
    trackers = @response.json_body
    assert_not_contains_entry trackers, 'id' => 5
  end

  test 'destroy fails deleting a tracker with related issue' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { id: 6 }.to_json
    delete :destroy, body: json

    parsed_response = @response.json_body
    assert_response :bad_request
    assert_equal ['Cannot delete tracker'], parsed_response['errors']

    get :show

    assert_response :success, @response.body
    trackers = @response.json_body
    assert_contains_entry trackers, 'id' => 6
  end
end