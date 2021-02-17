require File.expand_path('../../../../test_helper', __FILE__)

class ExtendedApi::V1::ExtendedEnumerationsControllerTest < ActionController::TestCase
  fixtures(
    :settings,
    :users,
    :custom_fields,
    :enumerations
  )

  test 'check for correct route generation' do
    path = 'extended_api/v1/enumerations'
    controller = 'extended_api/v1/extended_enumerations'
    assert_routing({ method: :get, path: path }, controller: controller, action: 'show')
    assert_routing({ method: :get, path: "#{path}/enumtypes" }, controller: controller, action: 'enum_types')
    assert_routing({ method: :get, path: "#{path}/:type/customfields" }, controller: controller, action: 'custom_fields', type: ':type')
    assert_routing({ method: :post, path: path }, controller: controller, action: 'create')
    assert_routing({ method: :patch, path: path }, controller: controller, action: 'update')
    assert_routing({ method: :delete, path: path }, controller: controller, action: 'destroy')
  end

  test 'show responds with 401 on unauthorized access' do
    request.headers.merge! TestHeaders::AUTH_HEADER_WRONG
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    get :show

    assert_response :unauthorized
  end

  test 'enum_types responds with 401 on unauthorized access' do
    request.headers.merge! TestHeaders::AUTH_HEADER_WRONG
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    get :enum_types

    assert_response :unauthorized
  end

  test 'custom_fields responds with 401 on unauthorized access' do
    request.headers.merge! TestHeaders::AUTH_HEADER_WRONG
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    get :custom_fields, params: { "type": 'IssuePriority' }

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

  test 'enum_types responds with 403 if user is not an admin' do
    request.headers.merge! TestHeaders::AUTH_HEADER_USER
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    get :enum_types

    assert_response :forbidden
    error = @response.json_body['errors']
    expected_error_message = ['Sie sind nicht berechtigt, auf diese Seite zuzugreifen.']
    assert_equal expected_error_message, error
  end

  test 'custom_fields responds with 403 if user is not an admin' do
    request.headers.merge! TestHeaders::AUTH_HEADER_USER
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    get :custom_fields, params: { "type": 'IssuePriority' }

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

  test 'show without type restriction lists entries of different types' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN

    get :show

    assert_response :success

    enumerations = @response.json_body

    assert_contains_entry enumerations, 'name' => 'CustomIssuePrio001', 'id' => 100
    assert_contains_entry enumerations, 'name' => 'CustomDocumentCategory001', 'id' => 200
  end

  test 'show with type restriction lists entries of the same types' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN

    get :show, params: { "type": 'IssuePriority' }

    assert_response :success

    enumerations = @response.json_body

    assert_contains_entry enumerations, 'name' => 'CustomIssuePrio001', 'id' => 100
    assert_contains_entry enumerations, 'name' => 'CustomIssuePrio002', 'id' => 101
    assert_not_contains_entry enumerations, 'name' => 'CustomDocumentCategory001', 'id' => 200
  end

  test 'show with wrong type restriction lists no entry' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN

    wrong_type_name = 'WrongTypeInfo'
    get :show, params: { "type": wrong_type_name }

    assert_response :not_found

    errors = @response.json_body['errors']

    expected_error_message = "could not find any enumeration of type '#{wrong_type_name}'"
    assert_equal [expected_error_message], errors
  end

  test 'create inserts a new entry for type TimeEntryActivity' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { "type": 'TimeEntryActivity', "name": 'TestTimeEntryActivity' }.to_json
    post :create, body: json

    assert_response :success
    id = @response.json_body['id']

    get :show, params: { "type": 'TimeEntryActivity' }

    created_entry = @response.json_body
    assert_contains_entry created_entry, 'name' => 'TestTimeEntryActivity', 'id' => id
  end

  test 'create fails inserting a new entry with wrong type' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER
    wrong_type_info = 'WrongType'
    json = { "type": wrong_type_info, "name": 'TestTimeEntryActivity' }.to_json
    post :create, body: json

    assert_response :bad_request
    assert_not_nil @response.json_body['errors']
    errors = @response.json_body['errors']
    expected_error_message = "could not create enumeration with type '#{wrong_type_info}'"
    assert errors[0].start_with? expected_error_message
  end

  test 'update updates the name of an existing entry' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    enumeration_id = 102

    json = { "id": enumeration_id, "name": 'UpdatedMe' }.to_json
    patch :update, body: json

    assert_response :success
    updated_enumeration = @response.json_body
    assert_contains_entry [updated_enumeration],
                          'id' => enumeration_id,
                          'name' => 'UpdatedMe'
  end

  test 'update fails updating a not existing entry' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    enumeration_id = 9999

    json = { "id": enumeration_id, "name": 'UpdatedMe' }.to_json
    patch :update, body: json

    assert_response :not_found

    errors = @response.json_body['errors']
    expected_error_message = "enumeration with id '#{enumeration_id}' could not be found"
    assert_equal [expected_error_message], errors
  end

  test 'destroy deletes an existing entry' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    enumeration_id = 103
    json = { "id": enumeration_id }.to_json
    delete :destroy, body: json

    assert_response :success
    deleted_enumeration = @response.json_body

    assert_contains_entry [deleted_enumeration],
                          'name' => 'DeleteMe',
                          'id' => enumeration_id

    get :show

    enumerations = @response.json_body
    assert_not_contains_entry enumerations,
                              'name' => 'DeleteMe',
                              'id' => enumeration_id
  end

  test 'destroy fails to delete a not existing entry' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    enumeration_id = 9999
    json = { "id": enumeration_id }.to_json
    delete :destroy, body: json

    assert_response :not_found

    errors = @response.json_body['errors']
    expected_error_message = "enumeration with id '#{enumeration_id}' could not be found"
    assert_equal [expected_error_message], errors
  end

  test 'enum_types delivers entries' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    get :enum_types

    assert_response :success

    found_types = @response.json_body
    expected_count_greater_than = 0
    assert found_types.count > expected_count_greater_than
  end

  test 'custom_fields responds with a single entry' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    get :custom_fields, params: { "type": 'IssuePriority' }

    assert_response :success

    custom_field_list = @response.json_body
    assert_contains_entry custom_field_list,
                          'id' => 5,
                          'name' => 'IssuePrioCF',
                          'format' => 'string'
  end

  test 'custom_fields responds with 400 for wrong type' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER
    wrong_type_info = 'WrongType'

    get :custom_fields, params: { "type": wrong_type_info }

    assert_response :bad_request
    assert_not_nil @response.json_body['errors']
    errors = @response.json_body['errors']
    expected_error_message = "could not create enumeration with type '#{wrong_type_info}'"
    assert errors[0].start_with? expected_error_message
  end
end