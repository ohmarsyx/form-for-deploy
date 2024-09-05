class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to root_path
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to root_path, status: :see_other
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :birthday, :gender, :email, :phone, :subject)
  end
end
