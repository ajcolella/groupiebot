require File.dirname(__FILE__)+'/application'
preload_app true

if Rails.env.development?

  worker_processes 1
  timeout_override = ENV['WEBSERVER_TIMEOUT_OVERRIDE']
  timeout Integer(timeout_override || 3600)
  if timeout_override
    puts "Development: Using WEBSERVER_TIMEOUT_OVERRIDE of #{timeout_override} seconds"
  end

  require 'byebug/core'

  def find_available_port
    server = TCPServer.new(nil, 0)
    server.addr[1]
  ensure
    server.close if server
  end

  port = find_available_port
  puts "Remote debugger on port #{port}"
  Byebug.wait_connection = true
  Byebug.start_server('localhost', port)
else
  worker_processes Integer(ENV["WEB_CONCURRENCY"] || 1)
  timeout 150000
end

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  if defined?(Resque)
    Rails.logger.info('Connected to Redis')
  end
end