module UsersHelper
  def format_basic_info time
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
  end

  def overtime_work(designated_work_end_time, end_plan_time)
    overtime = format("%.2f", ((end_plan_time - designated_work_end_time) / 60 ) / 60.0).to_f
    if overtime < 0
      overtime += 24.0
    end
    return overtime
  end

  def change_work_date(work_date, work_time)
    Time.new( work_date.year,
              work_date.month,
              work_date.day,
              work_time.hour,
              work_time.min,
              work_time.sec,
              "+09:00"
            )
  end
end
