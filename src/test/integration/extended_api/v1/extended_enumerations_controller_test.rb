require File.expand_path('../../../../test_helper', __FILE__)

class ExtendedApi::V1::ExtendedEnumerationsControllerTest < ActionController::TestCase
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
    assert_routing({ method: :get, path: 'extended_api/v1/enumerations' }, controller: 'extended_api/v1/extended_enumerations', action: 'show')
    assert_routing({ method: :post, path: 'extended_api/v1/enumerations' }, controller: 'extended_api/v1/extended_enumerations', action: 'create')
    assert_routing({ method: :patch, path: 'extended_api/v1/enumerations' }, controller: 'extended_api/v1/extended_enumerations', action: 'update')
    assert_routing({ method: :delete, path: 'extended_api/v1/enumerations' }, controller: 'extended_api/v1/extended_enumerations', action: 'destroy')
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

  test 'show without type restriction lists two entries' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    skip('tbd')
  end

  test 'show with type restriction lists one entries' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    skip('tbd')
  end

  test 'show with wrong type restriction lists no entry' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    skip('tbd')
  end

  test 'create inserts a new entry for type TimeEntryActivity' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER
    skip('tbd')
  end

  test 'create fails inserting a new entry with wrong type' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER
    skip('tbd')
  end

  test 'update updates the name of an existing entry' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER
    skip('tbd')
  end

  test 'update fails updating a not existing entry' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER
    skip('tbd')
  end

  test 'destroy deletes an existing entry' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER
    skip('tbd')
  end

  test 'destroy fails to delete a not existing entry' do
    request.headers.merge! TestHeaders::AUTH_HEADER_ADMIN
    request.headers.merge! TestHeaders::CONTENT_TYPE_JSON_HEADER
    skip('tbd')
  end
end