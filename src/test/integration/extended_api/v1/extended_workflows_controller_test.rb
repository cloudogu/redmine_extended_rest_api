require File.expand_path('../../../../test_helper', __FILE__)

class ExtendedApi::V1::ExtendedWorkflowsControllerTest < ActionController::TestCase
  fixtures(
    :settings,
    :users,
    :roles,
    :trackers,
    :issue_statuses
  )

  test 'check for correct route generation' do
    assert_routing({ method: :get, path: 'extended_api/v1/workflows' }, controller: 'extended_api/v1/extended_workflows', action: 'show')
    assert_routing({ method: :patch, path: 'extended_api/v1/workflows' }, controller: 'extended_api/v1/extended_workflows', action: 'update')
  end

  test 'show responds with 401 on unauthorized access' do
    request.headers.merge! TestHeaders::AUTH_HEADER_WRONG
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    get :show

    assert_response :unauthorized
  end

  test 'update responds with 401 on unauthorized access' do
    request.headers.merge! TestHeaders::AUTH_HEADER_WRONG
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    patch :update

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

  test 'update responds with 403 if user is not an admin' do
    request.headers.merge! TestHeaders::AUTH_HEADER_USER
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    patch :update

    assert_response :forbidden
    error = @response.json_body['errors']
    expected_error_message = ['Sie sind nicht berechtigt, auf diese Seite zuzugreifen.']
    assert_equal expected_error_message, error
  end

  test 'show lists all available workflow transitions' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    get :show

    assert_response :success, @response.body
  end

  test 'update updates two transitions for status 122' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = {
      role_id: [
        '1'
      ],
      tracker_id: [
        '1'
      ],
      transitions: {
        '122': {
          '133': { "always": '0', "author": '0', "assignee": '1' },
          '144': { "always": '1', "author": '0', "assignee": '0' }
        }
      },
    }.to_json
    patch :update, body: json

    assert_response :success

    get :show

    transitions = @response.json_body
    assert_contains_entry transitions,
                          'role_id' => 1,
                          'tracker_id' => 1,
                          'old_status_id' => 122,
                          'new_status_id' => 133,
                          'assignee' => true,
                          'author' => false
    assert_contains_entry transitions,
                          'role_id' => 1,
                          'tracker_id' => 1,
                          'old_status_id' => 122,
                          'new_status_id' => 144,
                          'assignee' => false,
                          'author' => false
  end
end