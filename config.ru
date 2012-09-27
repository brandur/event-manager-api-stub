require "bundler/setup"
Bundler.require

$stdout.sync = true

require "./event_manager_api_stub"
use Rack::Instruments
run EventManagerAPIStub
