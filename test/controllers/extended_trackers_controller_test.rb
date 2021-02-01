require File.expand_path('../../test_helper', __FILE__)

class ExtendedTrackersControllerTest < ActionController::TestCase
  fixtures :settings
  fixtures :users
  fixtures :trackers
  fixtures :issue_statuses

  def test_show_unauth
    authHeader = { :Authorization => "Basic YWRtaW46YWRtaW1=" }
    request.headers.merge! authHeader
    contentTypeHeader = { "Content-Type" => "application/json" }
    request.headers.merge! contentTypeHeader
    acceptHeader = { "Accept" => "application/json" }
    request.headers.merge! acceptHeader

    get :show

    assert_response :unauthorized
  end

  def test_show
    authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
    request.headers.merge! authHeader

    get :show

    assert_response :success, @response.body
    trackers = @response.json_body
    contains_entry_with_value trackers, "name", "Feature request"
    assert_contains_entry trackers, { "name" => "Feature request" }
  end

  test "create inserts a new tracker" do
    authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
    request.headers.merge! authHeader
    contentTypeHeader = { "Content-Type" => "application/json" }
    request.headers.merge! contentTypeHeader

    json = { tracker: { name: "megabug", "default_status_id": 55, "description": "my description" }}.to_json
    post :create, body: json

    assert_response :created

    get :show

    assert_response :success, @response.body
    trackers = @response.json_body
    assert_contains_entry trackers, { "name" => "megabug", "description" => "my description", "default_status_id" => 55 }
  end

  test "create fails if default status is missing" do
    authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
    request.headers.merge! authHeader
    contentTypeHeader = { "Content-Type" => "application/json" }
    request.headers.merge! contentTypeHeader

    json = { tracker: { name: "Megabug", "description": "my description" }}.to_json
    post :create, body: json

    parsed_response = @response.json_body
    assert_response :bad_request
    assert_equal ["muss ausgefüllt werden"], parsed_response['errors']['default_status']
  end

  test "create fails if tracker already exists" do
    authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
    request.headers.merge! authHeader
    contentTypeHeader = { "Content-Type" => "application/json" }
    request.headers.merge! contentTypeHeader

    json = { tracker: { name: "Bug", "default_status_id": 55, "description": "my description" }}.to_json
    post :create, body: json

    parsed_response = @response.json_body
    assert_response :bad_request
    assert_equal ["ist bereits vergeben"], parsed_response['errors']['name']
  end
end
