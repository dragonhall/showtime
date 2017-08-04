resque_workers: bundle exec rake resque:workers COUNT=2 QUEUE=default,mailers RAILS_ENV=production
resque_streaming: bundle exec rake resque:work QUEUE=streaming RAILS_ENV=production
resque_recording: bundle exec rake resque:workers COUNT=2 QUEUE=streaming RAILS_ENV=production
resque_scheduler: bundle exec rake resque:scheduler RAILS_ENV=production
