require "active_support/core_ext/time"
require "google/apis/calendar_v3"
require "./event.rb"

module Api
  SERVICE = Google::Apis::CalendarV3::CalendarService.new
  SERVICE.client_options.application_name = "queer scouts website"
  SERVICE.key = File.read(".google_api").chomp

  @@cached = nil

  def self.get(id, start_date, end_date=nil)
    if @@cached && @@cached.fresh?
      @@cached.events
    else
      @@cached = get_from_origin(id, start_date, end_date)
      @@cached.events
    end
  end

  def self.get_from_origin(id, start_date, end_date=nil)
    response = SERVICE.list_events(id, {
      single_events: true,
      order_by: "startTime",
      time_min: start_date.rfc3339,
      # time_max: end_date.rfc3339,
      fields: "items(htmlLink, iCalUID, start, end, summary, description, location)",
    })

    events = response.items.map { |item| Event.new(item) }
    ApiResponse.new(events)
  end

  def self.purge!
    @@cached = nil
  end
end

class ApiResponse
  attr_reader :events
  def initialize(events)
    @events = events
    @expiration = Time.zone.now.next_day
  end

  def fresh?
    !@expiration.past?
  end
end
