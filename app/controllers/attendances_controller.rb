class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_overtime_approval, :update_overtime_approval, :edit_attendance_approval, :update_attendance_approval, :attendance_log, :edit_onemonth_approval, :update_onemonth_approval]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :correct_user, only: [:edit_one_month, :update_one_month, :attendance_log]
  before_action :superior_user, only: [:edit_overtime_approval, :update_overtime_approval, :edit_attendance_approval, :update_attendance_approval, :edit_onemonth_approval, :update_onemonth_approval]
  before_action :not_admin_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  before_action :set_superiors, only: [:edit_one_month, :update_one_month]
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0), original_started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0), original_finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れさまでした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
        debugger
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.attributes = item
        if item[:edit_approval_superior].present?
          attendance.attendance_edit_request = "申請中"
        end
        attendance.save!(context: :update_one)  # この時だけon: :update_oneになっているバリデーションを実行する、save!で例外発生させてrescueに渡す
      end
    end
    flash[:success] = "1か月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあったため、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  def edit_overtime
    @user = User.find_by(id: params[:user_id])
    @superiors = User.where(superior: true).where.not(id: @user.id)
    @attendance = @user.attendances.find(params[:id])
  end

  def update_overtime
    @user = User.find_by(id: params[:user_id])
    @attendance = @user.attendances.find(params[:id])
    if @attendance.update_attributes(overtime_params)
      @attendance.overtime_request = "申請中"
      @attendance.save
      flash[:success] = "残業申請しました。"
    else
      flash[:danger] = "残業申請に失敗しました。"
    end
    redirect_to @user
  end

  def edit_overtime_approval
    @users = User.joins(:attendances).merge(Attendance.where(overtime_superior: @user.name)).group(:user_id)
  end

  def update_overtime_approval
    overtime_approval_params.each do |id, item|
      if item[:overtime_change] == "1"
        attendance = Attendance.find(id)
        attendance.overtime_request = item[:overtime_request]
        attendance.overtime_superior = "なし"
        attendance.save!
      end
    end
    redirect_to @user
  end

  def edit_attendance_approval
    @users = User.joins(:attendances).merge(Attendance.where(edit_approval_superior: @user.name)).group(:user_id)
  end

  def update_attendance_approval
    attendances_approval_params.each do |id, item|
      if item[:attendance_edit_change] == "1"
        attendance = Attendance.find(id)
        attendance.attendance_edit_request = item[:attendance_edit_request]
        attendance.edit_approval_superior = "なし"
        attendance.edit_approval_day = Date.today
        attendance.save!
      end
    end
    redirect_to @user
  end

  def attendance_log
    if params[:month].present?
      first_day = (params[:month] + "-1").to_date
      last_day = first_day.end_of_month
      this_month = [first_day..last_day]
    end
    @attendances = @user.attendances.where(worked_on: this_month).where(attendance_edit_request: "承認")
  end

  def update_onemonth_request
    @user = User.find(params[:user_id])
    attendance = Attendance.find(params[:id])
    if attendance.update_attributes(onemonth_request_params)
      flash[:success] = "所属長承認申請しました。"
    else
      flash[:danger] = "所属長承認申請に失敗しました。"
    end
    redirect_to @user
  end

  def edit_onemonth_approval
    @users = User.joins(:attendances).merge(Attendance.where(onemonth_approval_superior: @user.name)).group(:user_id)
  end

  def update_onemonth_approval
    onemonth_approval_params.each do |id, item|
      if item[:onemonth_approval_change] == "1"
        attendance = Attendance.find(id)
        attendance.onemonth_approval_request = item[:onemonth_approval_request]
        attendance.onemonth_approval_superior = "なし"
        attendance.save!
      end
    end
    redirect_to @user
  end
  
  private
    
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :edit_approval_superior])[:attendances]
    end

    def attendances_approval_params
      params.require(:user).permit(attendances: [:attendance_edit_request, :attendance_edit_change])[:attendances]
    end

    def overtime_params
      params.require(:attendance).permit(:end_plan_time, :overtime_next_day, :overtime_note, :overtime_superior)
    end

    def overtime_approval_params
      params.require(:user).permit(attendances: [:overtime_request, :overtime_change])[:attendances]
    end

    def onemonth_request_params
      params.require(:attendance).permit(:onemonth_approval_superior, :onemonth_approval_request)
    end

    def onemonth_approval_params
      params.require(:user).permit(attendances: [:onemonth_approval_request, :onemonth_approval_change])[:attendances]
    end
end
