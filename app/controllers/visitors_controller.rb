class VisitorsController < ApplicationController
  def queue_resque
    byebug
    Resque.enqueue(TwitterWorker)
    redirect_to root_path
  end
end
