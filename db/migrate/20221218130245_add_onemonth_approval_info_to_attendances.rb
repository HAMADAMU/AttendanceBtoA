class AddOnemonthApprovalInfoToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :onemonth_approval_request, :string
    add_column :attendances, :onemonth_approval_superior, :string
    add_column :attendances, :onemonth_approval_change, :string
  end
end
