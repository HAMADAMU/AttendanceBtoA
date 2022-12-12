class AddOvertimeInfoToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :end_plan_time, :time
    add_column :attendances, :next_day, :boolean
    add_column :attendances, :overtime_note, :string
    add_column :attendances, :overtime_request, :string
    add_column :attendances, :overtime_superior, :string
    add_column :attendances, :overtime_change, :string
  end
end
