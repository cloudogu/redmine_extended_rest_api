require File.expand_path('../../../../test_helper', __FILE__)

class ExtendedApi::V1::ExtendedIssueStatusesControllerTest < ActionController::TestCase
  fixtures(
    :settings,
    :users,
    :trackers,
    :issue_statuses,
    :issues,
    :projects,
  )

  test 'check for correct route generation' do
    assert_routing({ method: :get, path: 'extended_api/v1/issue_statuses' }, controller: 'extended_api/v1/extended_issue_statuses', action: 'show')
    assert_routing({ method: :post, path: 'extended_api/v1/issue_statuses' }, controller: 'extended_api/v1/extended_issue_statuses', action: 'create')
    assert_routing({ method: :patch, path: 'extended_api/v1/issue_statuses' }, controller: 'extended_api/v1/extended_issue_statuses', action: 'update')
    assert_routing({ method: :delete, path: 'extended_api/v1/issue_statuses' }, controller: 'extended_api/v1/extended_issue_statuses', action: 'destroy')
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

  test 'show responds with a list of issue statuses' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN

    get :show

    assert_response :success, @response.body
    issue_statuses = @response.json_body
    assert_contains_entry issue_statuses, 'name' => 'Assigned'
  end

  test 'create inserts a new issue status' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { name: 'test-status-001', "is_closed": '1' }.to_json
    post :create, body: json

    assert_response :created
    issue_status = @response.json_body
    assert_contains_entry [issue_status], 'name' => 'test-status-001', 'is_closed' => 'true'
  end

  test 'create fails if name is missing' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { issue_status: { "is_closed": '1' } }.to_json
    post :create, body: json

    parsed_response = @response.json_body
    assert_response :bad_request
    assert_equal ['muss ausgefüllt werden'], parsed_response['errors']['name']
  end

  test 'create fails if issue status already exists' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { name: 'Duplicate' }.to_json
    post :create, body: json

    parsed_response = @response.json_body
    assert_response :bad_request
    assert_equal ['ist bereits vergeben'], parsed_response['errors']['name']
  end

  test 'update updates the is_closed flag' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    status_id = 88

    json = { id: status_id, "is_closed": false }.to_json
    patch :update, body: json

    expected_fields = { 'id' => status_id, 'name' => 'UpdateClosedFlag', 'is_closed' => false }

    assert_response :success
    issue_status = @response.json_body
    assert_contains_entry [issue_status], expected_fields

    get :show
    assert_response :success, @response.body
    trackers = @response.json_body
    assert_contains_entry trackers, expected_fields
  end

  test 'destroy deletes a specific issue status' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { id: 99 }.to_json
    delete :destroy, body: json

    assert_response :success
    issue_status_id = @response.json_body
    assert_equal 99.to_s, issue_status_id['id'].to_s

    get :show

    assert_response :success, @response.body
    issue_statuses = @response.json_body
    assert_not_contains_entry issue_statuses, 'id' => 99
  end

  test 'destroy fails deleting an issue status with related tracker' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { id: 111 }.to_json
    delete :destroy, body: json

    parsed_response = @response.json_body
    assert_response :bad_request
    expected_error = ['Der Ticket-Status konnte nicht gelöscht werden. (This status is used as the default status by some trackers)']
    assert_equal expected_error, parsed_response['errors']

    get :show

    assert_response :success, @response.body
    trackers = @response.json_body
    assert_contains_entry trackers, 'id' => 111
  end
end