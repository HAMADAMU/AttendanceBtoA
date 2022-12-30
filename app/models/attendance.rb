class Attendance < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  validates :overtime_note, length: { maximum: 100 }
  
  validate :finished_at_is_invalid_without_a_started_at
  validate :started_at_than_finished_at_fast_if_invalid
  validate :started_at_is_invalid_without_a_finished_at, on: :update_one
  validate :end_plan_time_is_invalid_if_fast_than_designated_work_end_time, on: :update_overtime
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です。") if started_at.blank? && finished_at.present?
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      if (started_at > finished_at) && (attendance_next_day == false)
        errors.add(:started_at, "より早い退勤時間は無効です。")
      end
    end
  end
  
  def started_at_is_invalid_without_a_finished_at
    errors.add(:finished_at, "が必要です。") if finished_at.blank? && started_at.present?
  end

  def end_plan_time_is_invalid_if_fast_than_designated_work_end_time
    if (end_plan_time < change_work_date(worked_on, user.designated_work_end_time)) && overtime_next_day == false
      errors.add(:end_plan_time, "が不正な値です。")
    end
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
