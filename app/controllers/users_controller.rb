class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def authorize
    consumer = Dropbox::API::OAuth.consumer(:authorize)
    request_token = consumer.get_request_token
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
 
    redirect_to request_token.authorize_url(:oauth_callback => "http://#{request.host_with_port}/dropbox/callback")
 
  end
 
  def callback
    consumer = Dropbox::API::OAuth.consumer(:authorize)
    request_token = OAuth::RequestToken.new(consumer, session[:request_token], session[:request_token_secret])
    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_token])
    session[:access_token]  = access_token.token
    session[:secret_token] = access_token.secret
 
    @client = Dropbox::API::Client.new :token => session[:access_token], :secret => session[:secret_token]
    
    if @client.ls.any?
      @client.ls.each do |f|
        directory_hash(f)
      end
    end
    
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :document)
    end

  def directory_hash(obj)
    if obj.is_dir?
      list_hash(obj)
    else
      download_and_create(obj)
    end
  end
  
  def list_hash(obj)
    obj.ls.each do |s|
      directory_hash(s)
    end
  end
  
  def download_and_create(obj)
    path = download_file_from_url(obj)
    dp_file = File.open(path) if File.exists?(path)
    if dp_file
      DropboxFiles.create(:document => dp_file)
      File.delete(dp_file)
    end
  end
  
  def download_file_from_url(obj)
    destination_file_full_path = Rails.root.to_s + "/" + obj.path.to_s.split("/").last
    begin
      open(destination_file_full_path, 'wb') do |file|
        file << open(obj.direct_url.url).read
      end
    rescue
      puts "Exception occured while downloading..."
    end
    destination_file_full_path
  end
end
