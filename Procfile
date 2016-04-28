web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
resque: env TERM_CHILD=1 QUEUE=* RESQUE_TERM_TIMEOUT=7 bundle exec rake resque:work 
resque-scheduler: env bundle exec rake resque:scheduler
