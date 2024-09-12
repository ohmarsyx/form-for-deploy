class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
  end

  def modal
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace('modal', partial: 'modal', locals: { user: @user }) }
      format.html 
    end
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
      render :new, status: :unprocessable_entity 
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
  
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace('cards', partial: 'cards', locals: { users: User.all }),
          turbo_stream.remove('modal')
        ]
      end
      format.html { redirect_to users_path }
    end
  end
  
  

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :birthday, :gender, :email, :phone, :subject)
  end
end
