# frozen_string_literal: true

require "sinatra"
require "google/apis/calendar_v3"
require "active_support"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/time"
require "./event.rb"
require "./api.rb"
# require "fileutils"

Time.zone_default = ActiveSupport::TimeZone["America/New_York"]

CALENDAR_ID = "vfg030t77qemh643tvkb1jroj4@group.calendar.google.com"
SERVICE = Google::Apis::CalendarV3::CalendarService.new
SERVICE.client_options.application_name = "queerscouts.nyc"
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
	set :static_cache_control, :must_revalidate
end

configure :production do
	disable :static
end

get "/" do
	this_month = Time.zone.now.at_beginning_of_month
	# Cache responses in prod
	@items = if settings.production?
		Api.get(CALENDAR_ID, this_month)
	else
		Api.get_from_origin(CALENDAR_ID, this_month).events
	end

	erb :index
end
