require "multi_json"
require "sinatra"

class EventManagerAPIStub < Sinatra::Base
  REQUIRED_EVENT_FIELDS =
    %w{action actor_id actor cloud component timestamp}

  class APIError < RuntimeError
    attr_accessor :code
    def initialize(code, message="")
      super(message)
      @code = code
    end
  end

  configure do
    set :dump_errors,     false  # don't dump errors to stderr
    set :show_exceptions, false  # don't allow sinatra's crappy error pages
  end

  error [APIError, Exception] do
    e = env['sinatra.error']
    log(:error, :type => e.class.name, :message => e.message,
      :backtrace => e.backtrace)
    respond({ :message => e.message },
      :status => e.respond_to?(:code) ? e.code : 500)
  end

  helpers do
    def auth
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
    end

    def auth_credentials
      auth.provided? && auth.basic? ? auth.credentials : nil
    end

    def authorized!
      raise APIError.new(401, "Unauthorized") unless auth_credentials
    end

    def compare_fields!(required, actual)
      missing = required - actual
      if missing.count > 0
        raise APIError.new(422, "missing: #{missing}")
      end
    end

    def log(action, attrs={})
      Slides.log(action, attrs.merge!(:id => request.env["REQUEST_ID"]))
    end

    def respond(json, options={ :status => 200 })
      [options[:status], { "Content-Type" => "application/json" },
        MultiJson.encode(json, :pretty => true)]
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
