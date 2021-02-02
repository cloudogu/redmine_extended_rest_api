require File.expand_path('../../../../test_helper', __FILE__)
module ExtendedApi
  module V1
    class ExtendedIssueStatusesControllerTest < ActionController::TestCase
      fixtures(
        :settings,
        :users,
        :trackers,
        :issue_statuses,
        :issues,
        :projects,
      )

      test "check for correct route generation" do
        assert_routing({ method: :get, path: 'extended_api/v1/issue_statuses' }, { controller: "extended_api/v1/extended_issue_statuses", action: "show" })
        assert_routing({ method: :post, path: 'extended_api/v1/issue_statuses' }, { controller: "extended_api/v1/extended_issue_statuses", action: "create" })
        assert_routing({ method: :patch, path: 'extended_api/v1/issue_statuses' }, { controller: "extended_api/v1/extended_issue_statuses", action: "update" })
        assert_routing({ method: :delete, path: 'extended_api/v1/issue_statuses' }, { controller: "extended_api/v1/extended_issue_statuses", action: "destroy" })
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
        issue_statuses = @response.json_body
        assert_contains_entry issue_statuses, { "name" => "Assigned" }
      end

      test "create inserts a new issue status" do
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
        request.headers.merge! authHeader
        contentTypeHeader = { "Content-Type" => "application/json" }
        request.headers.merge! contentTypeHeader

        json = { issue_status: { name: "test-status-001", "is_closed": "1" } }.to_json
        post :create, body: json

        assert_response :created

        get :show

        assert_response :success, @response.body
        issue_statuses = @response.json_body
        puts issue_statuses
        assert_contains_entry issue_statuses, { "name" => "test-status-001", "is_closed" => "true" }
      end

      test "create fails if name is missing" do
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
        request.headers.merge! authHeader
        contentTypeHeader = { "Content-Type" => "application/json" }
        request.headers.merge! contentTypeHeader

        json = { issue_status: { "is_closed": "1" } }.to_json
        post :create, body: json

        parsed_response = @response.json_body
        assert_response :bad_request
        assert_equal ["muss ausgefüllt werden"], parsed_response['errors']['name']
      end

      test "create fails if issue status already exists" do
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
        request.headers.merge! authHeader
        contentTypeHeader = { "Content-Type" => "application/json" }
        request.headers.merge! contentTypeHeader

        json = { issue_status: { name: "Duplicate" } }.to_json
        post :create, body: json

        parsed_response = @response.json_body
        assert_response :bad_request
        assert_equal ["ist bereits vergeben"], parsed_response['errors']['name']
      end

      test "update updates the is_closed flag" do
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
        request.headers.merge! authHeader
        contentTypeHeader = { "Content-Type" => "application/json" }
        request.headers.merge! contentTypeHeader

        status_id = 88

        json = { id: status_id, issue_status: { "is_closed": "0" } }.to_json
        patch :update, body: json

        expected_fields = { "id" => status_id, "name" => "UpdateClosedFlag", "is_closed" => "false" }

        assert_response :success
        issue_status = @response.json_body
        puts issue_status
        assert_contains_entry [issue_status['issue_status']], expected_fields

        get :show
        assert_response :success, @response.body
        trackers = @response.json_body
        assert_contains_entry trackers, expected_fields
      end

      test "destroy deletes a specific issue status" do
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
        request.headers.merge! authHeader
        contentTypeHeader = { "Content-Type" => "application/json" }
        request.headers.merge! contentTypeHeader

        json = { id: 99 }.to_json
        delete :destroy, body: json

        assert_response :no_content

        get :show

        assert_response :success, @response.body
        issue_statuses = @response.json_body
        assert_not_contains_entry issue_statuses, { "id" => 99 }
      end

      test "destroy fails deleting an issue status with related tracker" do
        authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4=" }
        request.headers.merge! authHeader
        contentTypeHeader = { "Content-Type" => "application/json" }
        request.headers.merge! contentTypeHeader

        json = { id: 111 }.to_json
        delete :destroy, body: json

        parsed_response = @response.json_body
        assert_response :bad_request
        expected_error = "Der Ticket-Status konnte nicht gelöscht werden. (This status is used as the default status by some trackers)"
        assert_equal expected_error, parsed_response['errors']

        get :show

        assert_response :success, @response.body
        trackers = @response.json_body
        assert_contains_entry trackers, { "id" => 111 }
      end
    end
  end
end