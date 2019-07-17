# frozen_string_literal: true

require "sinatra"
require "google/apis/calendar_v3"
require "active_support"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/time"
require "./event.rb"
# require "fileutils"

Time.zone_default = ActiveSupport::TimeZone["America/New_York"]

APPLICATION_NAME = "queer scouts website"
SERVICE = Google::Apis::CalendarV3::CalendarService.new
SERVICE.client_options.application_name = APPLICATION_NAME
# https://console.developers.google.com
# -> create new app
# -> enable api
# ---> calendar api
# -> create credentials
# ---> api key
# -----> copy it down
# -----> restrict permissions
SERVICE.key = File.read(".google_api").chomp

configure do
  set :port, 3003
end

configure :production do
  disable :static
end

get "/" do
  this_month = Time.zone.now.at_beginning_of_month
  next_month = this_month.next_month
  # next_next_month = next_month.next_month
  response = SERVICE.list_events("vfg030t77qemh643tvkb1jroj4@group.calendar.google.com", {
    single_events: true,
    order_by: "startTime",
    time_min: this_month.rfc3339,
    time_max: next_month.rfc3339,
    fields: "items(htmlLink, iCalUID, start, end, summary, description, location)",
  })

  @items = response.items.map { |item| Event.new(item) }
  @first_day = this_month
  @last_day = next_month - 1

  erb :index
end
