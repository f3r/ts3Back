module ApiTestHelpers
  def json_response
    ActiveSupport::JSON.decode(response.body)
  end

  def assert_ok
    assert_response(200)
    assert_equal 'application/json', @response.content_type
    json = json_response
    assert_kind_of Hash, json
    assert_equal "ok", json['stat']
    json
  end

  def json_response_ok
    assert_ok
  end
end