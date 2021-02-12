require File.expand_path('../../../../test_helper', __FILE__)

class ExtendedApi::V1::ExtendedCustomFieldsControllerTest < ActionController::TestCase
  fixtures(
    :settings,
    :users,
    :trackers,
    :issue_statuses,
    :issues,
    :projects,
  )

  content_type_header = { 'Content-Type' => 'application/json' }
  auth_header_wrong = { :Authorization => 'Basic YWRtaW46YWRtaW1=' }
  auth_header = { :Authorization => 'Basic YWRtaW46YWRtaW4=' }

  test 'check for correct route generation' do
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
end