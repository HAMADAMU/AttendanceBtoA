class BasesController < ApplicationController
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
  end

  private
    def base_params
      params.require(:base).permit(:name, :number, :attend)
    end
end
