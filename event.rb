class Event
  def initialize(calendar_item)
    @item = calendar_item
  end

  def month
    start_date.month
  end

  def summary
    @item.summary
  end

  def description
    @item.description
  end

  def html_link
    @item.html_link
  end

  def location
    @item.location
  end

  def start_date
    @item.start.date_time || @item.start.date
  end

  def end_date
    @item.end.date_time || @item.end.date
  end

  def duration
    start_str, end_str =
      if start_date.is_a?(DateTime) && end_date.is_a?(DateTime)
        start_str = start_date.strftime("%a, %b %-d, %-I:%M %P")
        end_str = if same_day?(start_date, end_date)
          end_date.strftime("%-I:%M %P")
        else
          end_date.strftime("%a, %b %-d, %-I:%M %P")
        end
        [start_str, end_str]
      else
        days = days_between(start_date, end_date)
        start_str = start_date.strftime("%a, %b %-d")
        if days == 1
          [start_str]
        else
          end_str = (start_date + days - 1).strftime("%a, %b %-d")
          [start_str, end_str]
        end
      end

    [start_str, end_str].compact.join(" - ")
  end

  private

  def same_day?(date1, date2)
    date1.month == date2.month && date1.day == date2.day
  end

  def days_between(date1, date2)
    (date2 - date1).abs.to_i
  end

end
