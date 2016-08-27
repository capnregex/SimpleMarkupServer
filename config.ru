
app_path = File.expand_path('..', __FILE__)
lib_path = File.expand_path('lib', app_path)
public_path = File.expand_path('public', app_path)
$LOAD_PATH.unshift lib_path
require 'app'

# Do not buffer output
# $stdout.sync = true

# Get working dir, fixes issues when rackup is called outside app's dir
# app_path = Dir.pwd

use Rack::Static, :root => public_path

run App.new(public_path)

