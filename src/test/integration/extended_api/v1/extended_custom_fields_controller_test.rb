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

  content_type_header = { 'Content-Type' => 'application/json' }
  auth_header_wrong = { :Authorization => 'Basic YWRtaW46YWRtaW1=' }
  auth_header = { :Authorization => 'Basic YWRtaW46YWRtaW4=' }

  test 'check for correct route generation' do
    assert_routing({ method: :get, path: 'extended_api/v1/custom_fields' }, controller: 'extended_api/v1/extended_custom_fields', action: 'show')
    assert_routing({ method: :post, path: 'extended_api/v1/custom_fields' }, controller: 'extended_api/v1/extended_custom_fields', action: 'create')
    assert_routing({ method: :patch, path: 'extended_api/v1/custom_fields' }, controller: 'extended_api/v1/extended_custom_fields', action: 'update')
    assert_routing({ method: :delete, path: 'extended_api/v1/custom_fields' }, controller: 'extended_api/v1/extended_custom_fields', action: 'destroy')
  end

  test 'create responds with 401 on unauthorized access' do
    request.headers.merge! auth_header_wrong
    request.headers.merge! content_type_header

    post :create

    assert_response :unauthorized
  end

  test 'update responds with 401 on unauthorized access' do
    request.headers.merge! auth_header_wrong
    request.headers.merge! content_type_header

    patch :update

    assert_response :unauthorized
  end

  test 'destroy responds with 401 on unauthorized access' do
    request.headers.merge! auth_header_wrong
    request.headers.merge! content_type_header

    delete :destroy

    assert_response :unauthorized
  end

  test 'create inserts a new custom field' do
    request.headers.merge! auth_header
    request.headers.merge! content_type_header

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
    request.headers.merge! auth_header
    request.headers.merge! content_type_header

    json = { "type": 'IssueCustomField', "name": 'Duplicate', "field_format": 'int' }.to_json
    post :create, body: json

    assert_response :bad_request
    errors = @response.json_body['errors']
    assert_equal ['ist bereits vergeben'], errors[0]['name']
  end
end