# encoding: utf-8
require 'sinatra/base'
require 'action_view'
require 'feedzirra'
require 'time'
require 'redis'
require 'em-hiredis'
require 'thin'
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }


module JobFeed

  # making redis connection globally available
  def self.redis
    @redis ||= EM::Hiredis.connect("unix:///tmp/redis.sock")
  end


  # main loop
  EM.run do
    # Getting redis connection
    redis = JobFeed.redis

    # Starting WebServer mode
    Thin::Server.start 3000, App # '/tmp/thin.sock', App

    # Worker for updating feeds 
    EM.add_periodic_timer(60) do
      FeedUpdater.run
    end

    # Creating pubsub to subscribe on messages
    notifications = JobFeed.redis.pubsub
    notifications.subscribe("push_notification")

    # Callback on message from redis channel
    notifications.on(:message) do |channel, message|
      token = message[:token]
      number = message[:number]
      # here we will send push notification
    end


  end
end