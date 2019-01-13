class PicturesController < ApplicationController
  before_action :set_picture, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:index, :new, :create, :bulk_new, :bulk_create, :edit, :update, :destroy, :my_point_ranking, :my_histories]
  before_action :is_admin, only: [:edit, :update, :destroy, :blank_pictures]

  # GET /pictures
  # GET /pictures.json
  def index
    page_number = params[:page_number].present? ? params[:page_number] : params[:page]
    @pictures = Picture.all.order(id: :desc).page(page_number).per(20)
  end

  # GET /pictures/1
  # GET /pictures/1.json
  def show
  end

  # GET /pictures/new
  def new
    @picture = Picture.new
  end

  # GET /pictures/1/edit
  def edit
  end

  # POST /pictures
  # POST /pictures.json
  def create
    @picture = Picture.new(picture_params)
    @picture.url.sub!(/\?.*/, "")
    @picture.user_id = current_user.id

    respond_to do |format|
      if @picture.save
        format.html { redirect_to pictures_path, notice: 'Picture was successfully created.' }
        format.json { render :show, status: :created, location: @picture }
      else
        format.html { render :new }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  def bulk_new
  end

  def bulk_create
    #raise.params.inspect
    urls = params[:urls]
    urls = urls.gsub(/\r\n|\r|\n/, ",")#改行をカンマに変更
    urls = urls.split(",")#ひとつの文字列だったspをカンマで区切って配列にする
    @success = 0 #登録の成功した数をカウントする変数
    @fail = 0 #登録の失敗した数をカウントする変数

    urls.each do |url|
      url.sub!(/\?.*/, "")
      picture = Picture.new(url: url, user_id: current_user.id)
      if picture.save
        @success += 1 
      else
        @fail += 1
      end
    end

    render 'bulk_new'
  end

  # PATCH/PUT /pictures/1
  # PATCH/PUT /pictures/1.json
  def update
    respond_to do |format|
      if @picture.update(picture_params)
        format.html { redirect_to @picture, notice: 'Picture was successfully updated.' }
        format.json { render :show, status: :ok, location: @picture }
      else
        format.html { render :edit }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pictures/1
  # DELETE /pictures/1.json
  def destroy
    @picture.destroy

    @pictures = Picture.all.order(id: :desc).page(params[:page_number]).per(20)
    redirect_to pictures_path(page_number: params[:page_number])
    # respond_to do |format|
    #   format.html { redirect_to pictures_url, notice: 'Picture was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
  end

  def blank_pictures
    @pictures = Picture.where(picture_present: false).order(id: :desc).page(params[:page]).per(20)
    render 'index'
  end

  def point_ranking
    pictures_array = Picture.all.order(rating: :desc).limit(100).offset(0).pluck(:id)
    @pictures = Picture.where(id: pictures_array).order(rating: :desc).page(params[:page]).per(10)
    render 'ranking'
  end

  def win_ranking
    pictures_array = Picture.all.order(win: :desc).limit(100).offset(0).pluck(:id)
    @pictures = Picture.where(id: pictures_array).order(win: :desc).limit(100).offset(0).page(params[:page]).per(10)
    render 'ranking'
  end

  def my_point_ranking
    pictures_array = UserPicture.where(user_id: current_user.id).order(rating: :desc).limit(100).offset(0).pluck(:id)
    @pictures = UserPicture.where(id: pictures_array).order(rating: :desc).page(params[:page]).per(10)
    render 'ranking'
  end

  def my_histories
    pictures_array = UserPicture.where(user_id: current_user.id).where('win > ?', 0).order(voting_at: :desc).limit(100).offset(0).pluck(:id)
    @pictures = UserPicture.where(id: pictures_array).order(voting_at: :desc).page(params[:page]).per(10)
    render 'ranking'
  end

  private
    def set_picture
      @picture = Picture.find(params[:id])
    end

    def picture_params
      params.require(:picture).permit(:url)
    end
end
