require "bundler/setup"
Bundler.require

$stdout.sync = true

require "./facts_api_stub"
use Rack::Instruments
run EventManagerAPIStub
