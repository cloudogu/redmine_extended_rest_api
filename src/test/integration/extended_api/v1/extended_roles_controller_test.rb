require File.expand_path('../../../../test_helper', __FILE__)

class ExtendedApi::V1::ExtendedRolesControllerTest < ActionController::TestCase
  fixtures(
    :settings,
    :users,
    :projects,
    :roles,
    :members,
    :member_roles
  )

  test 'check for correct route generation' do
    assert_routing({ method: :get, path: 'extended_api/v1/roles' }, controller: 'extended_api/v1/extended_roles', action: 'show')
    assert_routing({ method: :post, path: 'extended_api/v1/roles' }, controller: 'extended_api/v1/extended_roles', action: 'create')
    assert_routing({ method: :patch, path: 'extended_api/v1/roles' }, controller: 'extended_api/v1/extended_roles', action: 'update')
    assert_routing({ method: :delete, path: 'extended_api/v1/roles' }, controller: 'extended_api/v1/extended_roles', action: 'destroy')
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

  test 'show responds with a list of roles' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN

    get :show

    assert_response :success, @response.body
    roles = @response.json_body
    contains_entry_with_value roles, 'name', 'Manager'
    assert_contains_entry roles, 'name' => 'Manager'
  end

  test 'create inserts a new role' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { name: 'TurboRole' }.to_json
    post :create, body: json

    assert_response :created
    role = @response.json_body
    assert_contains_entry [role], 'name' => 'TurboRole'
  end

  test 'create fails if name is missing' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { "time_entries_visibility": 'all' } .to_json
    post :create, body: json

    parsed_response = @response.json_body
    assert_response :bad_request
    assert_equal ['param is missing or the value is empty: name'], parsed_response['errors']
  end

  test 'create fails if role already exists' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { name: 'AlreadyExisting' }.to_json
    post :create, body: json

    parsed_response = @response.json_body
    assert_response :bad_request
    assert_equal ['ist bereits vergeben'], parsed_response['errors'][0]['name']
  end

  test 'update updates the name' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { id: 8, "name": 'newName' }.to_json
    patch :update, body: json

    assert_response :success
    role = @response.json_body
    assert_contains_entry [role], 'id' => 8, 'name' => 'newName'

    get :show
    assert_response :success, @response.body
    roles = @response.json_body
    assert_contains_entry roles, 'id' => 8, 'name' => 'newName'
  end

  test 'destroy deletes a specific role' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { id: 7 }.to_json
    delete :destroy, body: json

    assert_response :success
    role_data = @response.json_body
    assert_contains_entry [role_data], 'id' => 7, 'name' => 'Delete Me!'

    get :show

    assert_response :success, @response.body
    roles = @response.json_body
    assert_not_contains_entry roles, 'id' => 7
  end

  test 'destroy fails deleting a role which is assigned to a project' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { id: 6 }.to_json
    delete :destroy, body: json

    parsed_response = @response.json_body
    assert_response :bad_request
    assert_equal ['Cannot delete role'], parsed_response['errors']

    get :show

    assert_response :success, @response.body
    roles = @response.json_body
    assert_contains_entry roles, 'id' => 6
  end
end
