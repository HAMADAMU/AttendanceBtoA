module AttendancesHelper
  def times_15_min_round_up(time)
    if time < 15
      time = 0
    elsif time < 30
      time = 15
    elsif time < 45
      time = 30
    else
      time = 45
    end
  end
end