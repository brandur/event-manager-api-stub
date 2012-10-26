require "test_helper"

#
# just a couple tests to verify general sanity
#

describe EventManagerAPIStub do
  include Rack::Test::Methods

  def app
    EventManagerAPIStub
  end

  before do
    # suppress logging
    stub(Slides).log
  end

  describe "unauthenticated" do
    it "POST /v1/publish/event renders 401" do
      get "/v1/publish/event"
      last_response.status.must_equal 401
      MultiJson.decode(last_response.body).must_equal({
        "message" => "Unauthorized"
      })
    end
  end

  describe "authenticated" do
    before do
      authorize "", "secret"
    end

    it "POST /v1/publish/event without event renders 400" do
      post "/v1/publish/event"
      last_response.status.must_equal 400
    end

    it "POST /v1/publish/event with improper fields renders 422" do
      post "/v1/publish/event", "{}"
      last_response.status.must_equal 422
    end

    it "POST /v1/publish/event with an event is successful" do
      post "/v1/publish/event", MultiJson.encode({
        "action"     => "create_app",
        "actor_id"   => 1234,
        "actor"      => "user@heroku.com",
        "attributes" => {},
        "cloud"      => "heroku.com",
        "component"  => "core",
        "owner_id"   => 1234,
        "owner"      => "user@heroku.com",
        "target_id"  => 1234,
        "target"     => "my-heroku-app",
        "timestamp"  => 123412341324,
        "type"       => "app",
      })
      last_response.status.must_equal 201
    end

    it "GET /v1/events/:cloud gets events successfully" do
      get "/v1/events/heroku.com"
      MultiJson.decode(last_response.body).must_equal({
        "current" => "/v1/events/heroku.com/1342656521290",
        "older"   => "/v1/events/heroku.com/1342656510101",
        "events"  => {}
      })
    end

    it "GET /v1/events/:cloud/:before gets events successfully" do
      get "/v1/events/heroku.com/123412341324"
      MultiJson.decode(last_response.body).must_equal({
        "current" => "/v1/events/heroku.com/1342656521290",
        "older"   => "/v1/events/heroku.com/1342656510101",
        "events"  => {}
      })
    end

    it "GET /v1/events/app/:cloud/:app gets events successfully" do
      get "/v1/events/app/heroku.com/my-heroku-app"
      MultiJson.decode(last_response.body).must_equal({
        "current" => "/v1/events/app/heroku.com/my-heroku-app/1342656521290",
        "older"   => "/v1/events/app/heroku.com/my-heroku-app/1342656510101",
        "events"  => {}
      })
    end

    it "GET /v1/events/app/:cloud/:app/:before gets events successfully" do
      get "/v1/events/app/heroku.com/my-heroku-app/123412341324"
      MultiJson.decode(last_response.body).must_equal({
        "current" => "/v1/events/app/heroku.com/my-heroku-app/1342656521290",
        "older"   => "/v1/events/app/heroku.com/my-heroku-app/1342656510101",
        "events"  => {}
      })
    end
  end
end
