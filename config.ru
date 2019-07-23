# frozen_string_literal: true
require 'bundler'
Bundler.require :default, ENV['RACK_ENV']

Time.zone_default = ActiveSupport::TimeZone["America/New_York"]

require './lib/queerscouts.rb'

if QueerScouts.development?
  require "sinatra/reloader"
  QueerScouts.register Sinatra::Reloader
  Dir.glob("lib/**/*.rb") do |file|
    QueerScouts.also_reload(file)
  end
end

run QueerScouts

