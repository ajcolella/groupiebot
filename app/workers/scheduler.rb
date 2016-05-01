module Scheduler
  @queue = :master
  # The scheduler is responsible for queueing all workers.
  # Runs every 5min 
  # Queries the db for workers that are active and are due to be run

  def self.perform
    # Retreive active bots from db
    bots = Bot.where(status: 1)
    bots.each do |bot|
      worker = bot.platform.capitalize + "Worker"
      p "Queued #{worker} bot_id: #{bot.id}"
      Resque.enqueue(eval("#{worker}"), bot.id)
    end
  end
    

end