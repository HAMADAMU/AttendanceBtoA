class AddEditAttendanceApprovalToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :edit_approval_superior, :string
    add_column :attendances, :attendance_edit_request, :string
    add_column :attendances, :original_started_at, :datetime
    add_column :attendances, :original_finished_at, :datetime
  end
end
