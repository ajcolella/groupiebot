class TwitterBotsController < ApplicationController
  before_action :set_bot, only: [:show, :edit, :update, :destroy]
  before_action :format_params, only: [:create, :update]
  before_action :unformat_params, only: [:new, :edit]

  # GET /bots
  # GET /bots.json
  def index
  end

  # GET /bots/1
  # GET /bots/1.json
  def show
  end

  def queue_resque
    Resque.enqueue(TwitterWorker)
    render :show
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
    @twitter_bot = TwitterBot.new(bot_params)

    respond_to do |format|
      if @twitter_bot.save
        format.html { redirect_to bots_path, notice: 'Bot was successfully created.' }
        format.json { render :show, status: :created, location: @twitter_bot }
      else
        format.html { render :new }
        format.json { render json: @twitter_bot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bots/1
  # PATCH/PUT /bots/1.json
  def update
    respond_to do |format|
      if @twitter_bot.update(bot_params)
        format.html { redirect_to root_path, notice: 'Bot was successfully updated.' }
        format.json { render :show, status: :ok, location: @twitter_bot }
      else
        format.html { render :edit }
        format.json { render json: @twitter_bot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bots/1
  # DELETE /bots/1.json
  def destroy
    @twitter_bot.destroy
    respond_to do |format|
      format.html { redirect_to bots_url, notice: 'Bot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  private
    def unformat_params
      @twitter_bot.tags = @twitter_bot.tags.join(',')
    end

    def format_params
      params[:twitter_bot][:tags] = params[:twitter_bot][:tags].split(',')
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_bot
      @twitter_bot = TwitterBot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bot_params
      params.require(:twitter_bot).permit(:follow_back, :frequency, :follow_method, tags: [])
    end
end