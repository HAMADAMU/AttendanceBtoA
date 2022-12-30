class BasesController < ApplicationController
  before_action :admin_user, only: [:index, :create, :edit, :update, :destroy]

  def index
    @bases = Base.all
    @base = Base.new
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点情報を追加しました。"
      redirect_to bases_path
    else
      flash.now[:danger] = "拠点情報の追加に失敗しました。"
      @bases = Base.all
      render :index
    end
  end

  def edit
    @base = Base.find(params[:id])
  end

  def update
    @base = Base.find(params[:id])
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を修正しました。"
      redirect_to bases_path
    else
      flash.now[:danger] = "拠点情報の修正に失敗しました。"
      render :edit
    end
  end

  def destroy
    base = Base.find(params[:id])
    base.destroy
    flash[:success] = "#{base.name}を削除しました。"
    redirect_to bases_url
  end

  private
    def base_params
      params.require(:base).permit(:name, :number, :attend)
    end
end
