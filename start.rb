# encoding: utf-8
require 'sinatra/base'
require 'action_view'
require 'feedzirra'
require 'json'
require 'time'
require 'redis'
require 'em-hiredis'
require 'thin'
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }


module JobFeed

  # making redis connection globally available
  def self.redis
    @redis ||= EM::Hiredis.connect("unix:///tmp/redis.sock")
    # @redis ||= Redis.new(path: "/tmp/redis.sock")
  end


  # main loop
  EM.run do
    # Getting redis connection
    redis = JobFeed.redis

    # Starting WebServer mode
    @web_server = Thin::Server.start 3000, App # '/tmp/thin.sock', App

    # Worker for updating feeds 
    EM.add_periodic_timer(60) do
      FeedUpdater.run
    end

    # Creating pubsub to subscribe on messages
    notifications = JobFeed.redis.pubsub
    notifications.subscribe("push_notification") do |message|
      Pusher.run(message)
    end

    Signal.trap("INT") do
      EM.stop
    end

  end
end