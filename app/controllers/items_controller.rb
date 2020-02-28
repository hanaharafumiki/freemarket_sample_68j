class ItemsController < ApplicationController
  before_action :set_item, only: :edit

  def index
    @items = Item.all
    lac    = Item.group(:category_id).order('count_category_id DESC').count(:category_id).first
    category = lac[0]
    @cates = Item.where(sale: 0).where(category_id: category).first(3)
    @piccs = Image.where(item_id: @cates).distinct

    lab    = Item.group(:brand_id).order('count_brand_id DESC').count(:brand_id).first
    brand  = lab[0]
    @bras  = Item.where(sale: 0).where(brand_id: brand).first(3)
    @picbs = Image.where(item_id: @bras).distinct
  end

  def new
    @item = Item.new
    @parents = Category.where(ancestry: nil)
    @item.build_brand
    @item.images.new
  end
 
  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path, notice: '出品できました'
    else
      flash.now[:alert] = 'ちゃんと書いてください'
      render :new
    end
  end  

  def show
    @user = @item.user
    @category = @item.category
    @brand = @item.brand
    @images = @item.images
  end

  def search
    if params[:l_cat]
      @m_cat = Category.find(params[:l_cat]).children
    elsif params[:m_cat]
      @s_cat = Category.find(params[:m_cat]).children
    end

    respond_to do |format|
      format.html
      format.json 
    end
  end

  def edit
  end

  def update
    item.update(item_params)
  end

  def destroy
    if user_signed_in? && @item.user == current_user
      @item.destroy
      redirect_to root_path
    else 
      flash[:alert] = "削除に失敗しました"
    end
  end

  private
  def set_item
    @item = Item.find(params[:id])
  end
  
  def item_params
    params.require(:item).permit(:name, :price, :status, :description, :charge, :area, :day, :category_id, brand_attributes: [:id, :name], images_attributes: [:picture])
  end
end