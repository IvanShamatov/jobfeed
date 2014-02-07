require 'sinatra/base'
require 'action_view'
require 'feedzirra'
require 'json'
require 'time'
require 'redis'
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
require './app'

run JobFeed::App