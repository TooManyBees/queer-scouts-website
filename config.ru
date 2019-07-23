# frozen_string_literal: true
require 'bundler'
Bundler.require :default, ENV['RACK_ENV']

require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/time"
require "active_support/core_ext/date"
require "active_support/core_ext/date_time"

Time.zone_default = ActiveSupport::TimeZone["America/New_York"]

require './lib/queerscouts.rb'
run QueerScouts

