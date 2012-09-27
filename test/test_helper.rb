require "bundler/setup"
Bundler.require(:default, :test)

require "minitest/spec"
require "minitest/autorun"

require_relative "../event_manager_api_stub"

class MiniTest::Spec
  include RR::Adapters::TestUnit
end
