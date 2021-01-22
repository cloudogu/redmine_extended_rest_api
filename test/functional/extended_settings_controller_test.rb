require File.expand_path('../../test_helper', __FILE__)

class ExtendedSettingsControllerTest < ActionController::TestCase
  fixtures :settings

  # Replace this with your real tests.
  def test_show
    headers = { :Authorization => "Basic YWRtaW46YWRtaW4xMjM=" }
    request.headers.merge! headers
    get :show
    puts response.body
    assert true
  end

  def test_create
    authHeader = { :Authorization => "Basic YWRtaW46YWRtaW4xMjM=" }
    request.headers.merge! authHeader

    get :show
    puts response.body

    contentTypeHeader = { "Content-Type" => "application/json" }
    request.headers.merge! contentTypeHeader

    json = { settings: { app_title: "Minimine" }}.to_json
    post :create, body: json
    puts response.body
  end
end
