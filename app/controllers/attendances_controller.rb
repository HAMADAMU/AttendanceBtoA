class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_overtime_approval, :update_overtime_approval]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れさまでした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
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
    @attendance = @user.attendances.find(params[:id])
    @superiors = User.where(superior: true)
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
    # @attendances = Attendance.where(overtime_request: "申請中").where(overtime_superior: @user.name).order(:user_id).order(:worked_on)
  end

  def update_overtime_approval
  end
  
  private
    
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end

    def overtime_params
      params.require(:attendance).permit(:end_plan_time, :next_day, :overtime_note, :overtime_superior)
    end
end
