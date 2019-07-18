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
	QUEER_SCOUTS = "Queer Scouts NYC"

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

	FLAGS = [
		{ name: "Rainbow",
			colors:	%w{ #E40303 #FF8C00 #FFED00 #008026 #004DFF #750787 } },
		{ name: "Philadelphia",
			colors:	%w{ #000000 #784F17 #E40303 #FF8C00 #FFED00 #008026 #004DFF #750787 } },
		{ name: "Gilbert Baker's 1978",
			colors:	%w{ #FF69B6 #E70000 #FF8C00 #FFEF00 #00811F #00C1C1 #0044FF #760089 } },
		{ name: "Bisexual",
			colors:	%w{ #D9006F #744D98 #0033AB } },
		{ name: "Pansexual",
			colors:	%w{ #FF148C #FFDA00 #05AEFF } },
		{ name: "Transgender",
			colors:	%w{ #55CDFC #F7A8B8 #FFFFFF #F7A8B8 #55CDFC } },
		{ name: "Asexual",
			colors:	%w{ #000000 #A3A3A3 #FFFFFF #810082 } },
		{ name: "Aromantic",
			colors:	%w{ #3DA542 #A7D379 #FFFFFF #A9A9A9 #000000 } },
		{ name: "Agender",
			colors:	%w{ #000000 #B9B9B9 #FFFFFF #B8F483 #FFFFFF #B9B9B9 #000000 } },
		{ name: "Genderqueer",
			colors:	%w{ #B57EDC #FFFFFF #4A8123 } },
		{ name: "Nonbinary",
			colors:	%w{ #FFF430 #FFFFFF #9C59D1 #000000 } },
		{ name: "Genderfluid",
			colors:	%w{ #FB72BF #FEFDFE #D414DA #020202 #094EC5 } },
		{ name: "Intersex",
			colors: %i{ intersex } },
	]

	def random_heart_flag
		flag = FLAGS.sample
		label = "Heart emoji in #{flag[:name]} Pride colors"
		hearts = flag[:colors]
			.map do |color|
				style = if color == :intersex
					'background-image: radial-gradient(circle at center 45%, #FFDA00, #FFDA00 15%, #7902AA 17%, #7902AA 30%, #FFDA00 32%, #FFDA00);'
				else
					"--color:#{color};"
				end
				"<span style=\"#{style}\" aria-hidden=\"true\">♥︎</span>"
			end
			.join
			.html_safe
		%[<span class="flag" aria-label="#{label}" title="#{label}">#{hearts}</span>]
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

get "/code-of-conduct/?", "/code_of_conduct/?", "/codeofconduct/?", "/conduct/?" do
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

# post "/api/update" do
# 	# validate token or whatever
# 	# header X-Goog-Channel-Token
# 	# https://console.developers.google.com/apis/credentials/domainverification?project=queer-scouts-test-app&folder&organizationId
# 	Api.purge!
# end
