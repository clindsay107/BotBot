class BotsController < ApplicationController

  def new
    render :new
  end

  def create
    bot = Bot.new(bot_params)

    if bot.save
      bot.run
    end
    redirect_to new_bot_url
  end

  private

  def bot_params
    params.require(:bot).permit(:nickname, :server, :port, :password)
  end
end
