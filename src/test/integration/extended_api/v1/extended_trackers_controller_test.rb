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

  accept_header = { "Accept" => "application/json" }
  content_type_header = { "Content-Type" => "application/json" }
  auth_header_wrong = { :Authorization => "Basic YWRtaW46YWRtaW1=" }
  auth_header = { :Authorization => "Basic YWRtaW46YWRtaW4=" }

  test "check for correct route generation" do
    assert_routing({ method: :get, path: 'extended_api/v1/trackers' }, { controller: "extended_api/v1/extended_trackers", action: "show" })
    assert_routing({ method: :post, path: 'extended_api/v1/trackers' }, { controller: "extended_api/v1/extended_trackers", action: "create" })
    assert_routing({ method: :patch, path: 'extended_api/v1/trackers' }, { controller: "extended_api/v1/extended_trackers", action: "update" })
    assert_routing({ method: :delete, path: 'extended_api/v1/trackers' }, { controller: "extended_api/v1/extended_trackers", action: "destroy" })
  end

  test "show responds with 401 on unauthorized access" do
    request.headers.merge! auth_header_wrong
    request.headers.merge! content_type_header
    request.headers.merge! accept_header

    get :show

    assert_response :unauthorized
  end

  test "show responds with a list of trackers" do
    request.headers.merge! auth_header

    get :show

    assert_response :success, @response.body
    trackers = @response.json_body
    contains_entry_with_value trackers, "name", "Feature request"
    assert_contains_entry trackers, { "name" => "Feature request" }
  end

  test "create inserts a new tracker" do
    request.headers.merge! auth_header
    request.headers.merge! content_type_header

    json = { tracker: { name: "megabug", "default_status_id": 55, "description": "my description" } }.to_json
    post :create, body: json

    assert_response :created

    get :show

    assert_response :success, @response.body
    trackers = @response.json_body
    assert_contains_entry trackers, { "name" => "megabug", "description" => "my description", "default_status_id" => 55 }
  end

  test "create fails if default status is missing" do
    request.headers.merge! auth_header
    request.headers.merge! content_type_header

    json = { tracker: { name: "Megabug", "description": "my description" } }.to_json
    post :create, body: json

    parsed_response = @response.json_body
    assert_response :bad_request
    assert_equal ["muss ausgefüllt werden"], parsed_response['errors']['default_status']
  end

  test "create fails if tracker already exists" do
    request.headers.merge! auth_header
    request.headers.merge! content_type_header

    json = { tracker: { name: "Bug", "default_status_id": 55, "description": "my description" } }.to_json
    post :create, body: json

    parsed_response = @response.json_body
    assert_response :bad_request
    assert_equal ["ist bereits vergeben"], parsed_response['errors']['name']
  end

  test "update updates the description" do
    request.headers.merge! auth_header
    request.headers.merge! content_type_header

    json = { id: 4, tracker: { "description": "my description" } }.to_json
    patch :update, body: json

    assert_response :success
    trackers = @response.json_body
    assert_contains_entry [trackers['tracker']], { "id" => 4, "name" => "Bug Request", "description" => "my description", "default_status_id" => 55 }

    get :show
    assert_response :success, @response.body
    trackers = @response.json_body
    assert_contains_entry trackers, { "id" => 4, "name" => "Bug Request", "description" => "my description", "default_status_id" => 55 }
  end

  test "destroy deletes a specific tracker" do
    request.headers.merge! auth_header
    request.headers.merge! content_type_header

    json = { id: 5 }.to_json
    delete :destroy, body: json

    assert_response :no_content

    get :show

    assert_response :success, @response.body
    trackers = @response.json_body
    assert_not_contains_entry trackers, { "id" => 5 }
  end

  test "destroy fails deleting a tracker with related issue" do
    request.headers.merge! auth_header
    request.headers.merge! content_type_header

    json = { id: 6 }.to_json
    delete :destroy, body: json

    parsed_response = @response.json_body
    assert_response :bad_request
    assert_equal "Cannot delete tracker", parsed_response['errors']

    get :show

    assert_response :success, @response.body
    trackers = @response.json_body
    assert_contains_entry trackers, { "id" => 6 }
  end
end