class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:show, :edit, :update, :edit_basic_info, :update_basic_info]
  before_action :admin_user, only: [:index, :index_of_working, :destroy, :edit_basic_info, :update_basic_info]
  before_action :not_admin_user, only: :show
  before_action :superior_or_correct_user, only: :show
  before_action :set_one_month, only: :show
  before_action :set_superiors, only: :show
  
  def index
    if params[:search].present?
      @users = User.where('name LIKE ?', "%#{params[:search]}%").paginate(page: params[:page]) if params[:search].present?
      @h1_title = "検索結果"
    else
      @users = User.paginate(page: params[:page])
      @h1_title = "全ユーザー一覧"
    end
  end

  def index_of_working
    @users = User.joins(:attendances).merge(Attendance.where(worked_on: Date.today).where.not(started_at: nil).where(finished_at: nil))
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil, finished_at: nil).count
    @first_attendance = @attendances.find_by(worked_on: @first_day)
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_posts_csv(@attendances)
      end
    end
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "新規登録しました。"
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を編集しました。"
      redirect_to users_path
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    users = User.all
    ActiveRecord::Base.transaction do
      users.each { |user| user.update_attributes!(basic_info_params) }
    end
    flash[:success] = "全ユーザーの基本情報を更新しました。"
    redirect_to root_url
      
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "全ユーザーの基本情報の更新に失敗しました。"
    render :edit_basic_info
  end

  def import
    User.import(params[:file])
    redirect_to users_path
  end
  
  private
    
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation, :employee_number, :uid, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
    def basic_info_params
      params.require(:user).permit(:basic_work_time, :designated_work_start_time)
    end

    def send_posts_csv(attendances)
      csv_data = CSV.generate do |csv|
        column_names = %w(日付 出勤時間 退勤時間)
        csv << column_names
        @attendances.each do |attendance|
          if attendance.attendance_edit_request == "承認"
            start = l(attendance.started_at, format: :time) if attendance.started_at.present?
            finish = l(attendance.finished_at, format: :time) if attendance.finished_at.present?
            column_values = [
              l(attendance.worked_on, format: :short),
              start,
              finish
            ]
          else
            start = l(attendance.original_started_at, format: :time) if attendance.original_started_at.present?
            finish = l(attendance.original_finished_at, format: :time) if attendance.original_finished_at.present?
            column_values = [
              l(attendance.worked_on, format: :short),
              start,
              finish
            ]
          end
          csv << column_values
        end
      end
      send_data(csv_data, filename: "#{@user.name}_#{@first_day.mon}月_勤怠.csv")
    end
end
