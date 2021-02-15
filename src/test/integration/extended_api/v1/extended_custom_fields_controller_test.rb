require File.expand_path('../../../../test_helper', __FILE__)

class ExtendedApi::V1::ExtendedCustomFieldsControllerTest < ActionController::TestCase
  fixtures(
    :settings,
    :users,
    :trackers,
    :issue_statuses,
    :issues,
    :projects,
    :custom_fields
  )

  test 'check for correct route generation' do
    assert_routing({ method: :get, path: 'extended_api/v1/custom_fields' }, controller: 'extended_api/v1/extended_custom_fields', action: 'show')
    assert_routing({ method: :post, path: 'extended_api/v1/custom_fields' }, controller: 'extended_api/v1/extended_custom_fields', action: 'create')
    assert_routing({ method: :patch, path: 'extended_api/v1/custom_fields' }, controller: 'extended_api/v1/extended_custom_fields', action: 'update')
    assert_routing({ method: :delete, path: 'extended_api/v1/custom_fields' }, controller: 'extended_api/v1/extended_custom_fields', action: 'destroy')
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

  test 'show lists a set of custom fields' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    get :show

    assert_response :success
    custom_field_list = @response.json_body
    assert_contains_entry custom_field_list,
                          'id' => 3,
                          'name' => 'my-int-field',
                          'field_format' => 'int'
  end

  test 'create inserts a new custom field' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { "type": 'IssueCustomField', "name": 'Super Points X', "field_format": 'int' }.to_json
    post :create, body: json

    assert_response :created
    created_field = @response.json_body
    new_field_id = created_field['id']

    get :show

    assert_response :success, @response.body
    custom_fields = @response.json_body
    assert_contains_entry custom_fields,
                          'name' => 'Super Points X',
                          'field_format' => 'int',
                          'id' => new_field_id
  end

  test 'create inserts fails with duplicated name' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { "type": 'IssueCustomField', "name": 'Duplicate', "field_format": 'int' }.to_json
    post :create, body: json

    assert_response :bad_request
    errors = @response.json_body['errors']
    assert_equal ['ist bereits vergeben'], errors[0]['name']
  end

  test 'update updates the name of an existing custom field' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    custom_field_id = 4

    json = { "id": custom_field_id, "name": 'UpdatedMe' }.to_json
    patch :update, body: json

    assert_response :success
    updated_field = @response.json_body
    assert_contains_entry [updated_field],
                          'id' => custom_field_id,
                          'name' => 'UpdatedMe',
                          'field_format' => 'int'
  end

  test 'update fails updating a not existing custom field' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    json = { "id": 999_999, "name": 'UpdatedMe', "field_format": 'list' }.to_json
    patch :update, body: json

    assert_response :not_found
    errors = @response.json_body['errors']
    expected_error_message = 'custom field with id \'999999\' could not be found'
    assert_equal [expected_error_message], errors

  end

  test 'destroy deletes an existing custom field' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    custom_field_id = 2
    json = { "id": custom_field_id }.to_json
    delete :destroy, body: json

    assert_response :success
    deleted_field = @response.json_body

    assert_contains_entry [deleted_field],
                          'name' => 'DeleteMe',
                          'field_format' => 'list',
                          'id' => custom_field_id
  end

  test 'destroy fails deleting a not existing custom field' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    custom_field_id = 999_999
    json = { "id": custom_field_id }.to_json
    delete :destroy, body: json

    assert_response :not_found
    errors = @response.json_body['errors']
    expected_error_message = "custom field with id '999999' could not be found"
    assert_equal [expected_error_message], errors
  end

  test 'types lists the available field types' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER

    get :types

    assert_response :success
    types_list = @response.json_body
    assert_includes types_list, 'IssueCustomField'
    assert_includes types_list, 'TimeEntryActivityCustomField'
  end
end