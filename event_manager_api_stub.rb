require "multi_json"

class EventManagerAPIStub < Sinatra::Base
  REQUIRED_EVENT_FIELDS =
    %w{action actor_id actor cloud component target_id target timestamp type}

  helpers do
    def auth
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
    end

    def auth_credentials
      auth.provided? && auth.basic? ? auth.credentials : nil
    end

    def authorized!
      raise APIError.new(401) unless auth_credentials
    end

    def compare_fields!(required, actual)
      missing = required - actual
      if missing.count > 0
        raise APIError.new(422, "missing: #{missing}")
      end
    end

    def respond(json, options={ :status => 200 })
      [options[:status], { "Content-Type" => "application/json" },
        MultiJson.encode(json, :pretty => true)]
    end
  end

  class APIError < StandardError
    attr_accessor :code
    def initialize(code, message="")
      super(message)
      @code = code
    end
  end

  before do
    authorized!
  end

  post "/v1/publish/event" do
    event = MultiJson.decode(request.body.read) rescue raise(APIError.new(400))
    compare_fields!(REQUIRED_EVENT_FIELDS, event.keys)
    respond(event, :status => 201)
  end

  get "/v1/events/app/:cloud/:app/?:before?" do |cloud, app, before|
    respond({
      "current" => "/v1/events/app/heroku.com/#{app}/1342656521290",
      "older"   => "/v1/events/app/heroku.com/#{app}/1342656510101",
      "events"  => {}
    })
  end

  get "/v1/events/:cloud/?:before?" do |cloud, before|
    respond({
      "current" => "/v1/events/heroku.com/1342656521290",
      "older"   => "/v1/events/heroku.com/1342656510101",
      "events"  => {}
    })
  end
end
