class BotsController < ApplicationController
  before_action :set_bot, only: [:show, :edit, :update, :destroy]

  # GET /bots
  # GET /bots.json
  def index
    # Check rate limits here
    @bots = Bot.where(user_id: current_user).order(created_at: :desc)
    @bots.each { |b| b.update_bot_details }
  end

  # GET /bots/1
  # GET /bots/1.json
  def show
  end

  # GET /bots/new
  def new
  end

  # GET /bots/1/edit
  def edit
  end

  # POST /bots
  # POST /bots.json
  def create
    bot_params[:user_id] = current_user
    @bot = Bot.new(bot_params)

    respond_to do |format|
      if @bot.save
        format.html { redirect_to @bot, notice: 'Bot was successfully created.' }
        format.json { render :show, status: :created, location: @bot }
      else
        format.html { render :new }
        format.json { render json: @bot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bots/1
  # PATCH/PUT /bots/1.json
  def update
    respond_to do |format|
      if @bot.update(bot_params)
        format.html { redirect_to @bot, notice: 'Bot was successfully updated.' }
        format.json { render :show, status: :ok, location: @bot }
      else
        format.html { render :edit }
        format.json { render json: @bot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bots/1
  # DELETE /bots/1.json
  def destroy
    @bot.destroy
    @child_bot.destroy
    respond_to do |format|
      format.html { redirect_to bots_url, notice: 'Bot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bot
      @bot = Bot.find(params[:id])
      @child_bot = eval("@bot.#{@bot.platform.downcase}_bot")
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bot_params
      params.require(:bot).permit(:status, :platform).merge(user_id: current_user.id)
    end
end
