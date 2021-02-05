require File.expand_path('../../../../test_helper', __FILE__)

class ExtendedApi::V1::ExtendedWorkflowsControllerTest < ActionController::TestCase
  fixtures(
    :settings,
    :users,
    :roles,
    :trackers,
    :issue_statuses
  )

  accept_header = { 'Accept' => 'application/json' }
  content_type_header = { 'Content-Type' => 'application/json' }
  auth_header_wrong = { :Authorization => 'Basic YWRtaW46YWRtaW1=' }
  auth_header = { :Authorization => 'Basic YWRtaW46YWRtaW4=' }

  test 'check for correct route generation' do
    assert_routing({ method: :get, path: 'extended_api/v1/workflows' }, controller: 'extended_api/v1/extended_workflows', action: 'show')
    assert_routing({ method: :patch, path: 'extended_api/v1/workflows' }, controller: 'extended_api/v1/extended_workflows', action: 'update')
  end

  test 'show responds with 401 on unauthorized access' do
    request.headers.merge! auth_header_wrong
    request.headers.merge! content_type_header
    request.headers.merge! accept_header

    get :show

    assert_response :unauthorized
  end

  test 'patch responds with 401 on unauthorized access' do
    request.headers.merge! auth_header_wrong
    request.headers.merge! content_type_header
    request.headers.merge! accept_header

    patch :update

    assert_response :unauthorized
  end

  test 'show lists all available workflow transitions' do
    request.headers.merge! auth_header
    request.headers.merge! content_type_header

    get :show

    assert_response :success, @response.body
  end

  test 'update updates two transitions for status 122' do
    request.headers.merge! auth_header
    request.headers.merge! content_type_header

    json = {
      role_id: [
        '1'
      ],
      tracker_id: [
        '1'
      ],
      transitions: [
        {
          src_status_id: '122',
          transitions: [
            {
              target_status_id: '133',
              types: [
                {
                  name: 'always',
                  active: '0'
                },
                {
                  name: 'author',
                  active: '0'
                },
                {
                  name: 'assignee',
                  active: '1'
                }
              ]
            },
            {
              target_status_id: '144',
              types: [
                {
                  name: 'always',
                  active: '1'
                },
                {
                  name: 'author',
                  active: '0'
                },
                {
                  name: 'assignee',
                  active: '0'
                }
              ]
            }
          ]
        }
      ],
    }.to_json
    patch :update, body: json
    botty = @response.json_body
    assert_response :success

    get :show

    transitions = @response.json_body
    assert_contains_entry transitions,
                          'role_id' => 1,
                          'old_status_id' => 122,
                          'new_status_id' => 133,
                          'assignee' => true,
                          'author' => false
  end
end