class EventManagerAPIStub < Sinatra::Base
  EVENT_FIELDS =
    %w{action actor attributes cloud component owner target timestamp type}

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
      extra   = actual - required

      if missing.count > 0 || extra.count > 0
        Slides.log :compare_fields!, :missing => missing, :extra => extra
        raise APIError.new(422)
      end
    end

    def respond(json, options={ status: 200 })
      [options[:status], { "Content-Type" => "application/json" },
        MultiJson.encode(json, :pretty => true)]
    end
  end

  class APIError < StandardError
    attr_accessor :code
    def initialize(code)
      @code = code
    end
  end

  before do
    authorized!
  end

  post "/v1/publish/event" do
    event = MultiJson.decode(request.body.read) rescue raise(APIError.new(400))
    compare_fields!(EVENT_FIELDS, event.keys)
    respond(event, :status => 201)
  end
end
