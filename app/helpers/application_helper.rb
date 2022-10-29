module ApplicationHelper
  
  def full_title(page_name = "")
    base_title = "Sample"
    if page_name.empty?
      base_title
    else
      page_name + " | " + base_title
    end
  end
  
  def day_color(wday)
    if wday == 0
      "sunday"
    elsif wday == 6
      "saturday"
    else
      "weekday"
    end
  end
end
