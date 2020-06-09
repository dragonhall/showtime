# frozen_string_literal: true

require 'yaml'
require 'resque/server'
require 'resque/scheduler/server'
require 'active_scheduler'

redis_url = YAML.load_file(Rails.root.join('config', 'redis.yml'))[Rails.env.to_s] # rescue 'redis://localhost:6379/0'

REDIS_APPKEY = Rails.application.class.name.underscore.split('/').first

puts " >> Initializing Redis at #{redis_url}"
# Resque.redis = Redis::Namespace.new(REDIS_APPKEY.to_sym, redis: Redis::Client.new(url: redis_url))
# redis = Redis::Namespace.new(REDIS_APPKEY.to_sym, redis: Redis::Client.new(url: redis_url))
redis = Redis.new(url: redis_url)
redis_ns = Redis::Namespace.new(REDIS_APPKEY.to_sym, redis: redis)

Redis.current = redis_ns

yaml_schedule    = YAML.load_file(Rails.root.join('config', 'resque_schedule.yaml')) || {}
wrapped_schedule = ActiveScheduler::ResqueWrapper.wrap yaml_schedule

Resque.redis     = redis_ns
Resque.schedule  = wrapped_schedule
