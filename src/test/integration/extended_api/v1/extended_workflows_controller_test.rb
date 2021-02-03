require File.expand_path('../../../../test_helper', __FILE__)

class ExtendedApi::V1::ExtendedWorkflowsControllerTest < ActionController::TestCase
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

  test "show lists all available workflow transitions" do
    request.headers.merge! auth_header
    request.headers.merge! content_type_header

    get :show

    assert_response :success, @response.body
  end
end