# frozen_string_literal: true

require "erubis"
require "sinatra"
require "sinatra/multi_route"
require "sinatra/content_for"
require "google/apis/calendar_v3"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/time"
require "./event.rb"
require "./api.rb"

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
	set :erb, :escape_html => true
end

configure :production do
	disable :static
end

helpers do
	def strip_trailing_slashes
		return if request.path == "/"
		if request.path.end_with?("/")
			redirect to(request.path.chomp("/")), 301
			true
		end
	end

	def link_unless_current path, text, klass=nil
		if path == request.path
			text
		elsif path == request.path.chomp("/")
			text
		else
			klass = "class=\"#{klass}\"" if klass
			href = "href=\"#{path}\""
			"<a #{klass} #{href}>#{text}</a>".html_safe
		end
	end
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

get "/about/?" do
	strip_trailing_slashes and next
	erb :about
end

get "/code-of-conduct/?", "/code_of_conduct/?", "/codeofconduct/?" do
	redirect to("/coc"), 301
end

get "/coc/?" do
	strip_trailing_slashes and next
	erb :coc
end

get "/contact/?" do
	strip_trailing_slashes and next
	erb :contact
end

