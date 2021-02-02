require File.expand_path('../../../../test_helper', __FILE__)
module ExtendedApi
  module V1
    class ExtendedTrackersControllerTest < ActionController::TestCase
      fixtures(
        :settings,
        :users,
        :trackers,
        :issue_statuses,
        :issues,
        :projects,
      )

      test "check for correct route generation" do
        assert_routing({ method: :get, path: 'extended_api/v1/trackers' }, { controller: "extended_api/v1/extended_trackers", action: "show" })
        assert_routing({ method: :post, path: 'extended_api/v1/trackers' }, { controller: "extended_api/v1/extended_trackers", action: "create" })
        assert_routing({ method: :patch, path: 'extended_api/v1/trackers' }, { controller: "extended_api/v1/extended_trackers", action: "update" })
        assert_routing({ method: :delete, path: 'extended_api/v1/trackers' }, { controller: "extended_api/v1/extended_trackers", action: "destroy" })
      end

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

        json = { tracker: { name: "megabug", "default_status_id": 55, "description": "my description" } }.to_json
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

        json = { tracker: { name: "Megabug", "description": "my description" } }.to_json
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

        json = { tracker: { name: "Bug", "default_status_id": 55, "description": "my description" } }.to_json
        post :create, body: json

        parsed_response = @response.json_body
        assert_response :bad_request
        assert_equal ["ist bereits vergeben"], parsed_response['errors']['name']
      end

      test "update updates the description" do
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
        request.headers.merge! authHeader
        contentTypeHeader = { "Content-Type" => "application/json" }
        request.headers.merge! contentTypeHeader

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
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
        request.headers.merge! authHeader
        contentTypeHeader = { "Content-Type" => "application/json" }
        request.headers.merge! contentTypeHeader

        json = { id: 5 }.to_json
        delete :destroy, body: json

        assert_response :no_content

        get :show

        assert_response :success, @response.body
        trackers = @response.json_body
        assert_not_contains_entry trackers, { "id" => 5 }
      end

      test "destroy fails deleting a tracker with related issue" do
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
        request.headers.merge! authHeader
        contentTypeHeader = { "Content-Type" => "application/json" }
        request.headers.merge! contentTypeHeader

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
  end
end