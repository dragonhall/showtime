def monit_do(*args)
  on roles :app do
    execute :echo 
    # execute :sudo, :monit, *args
  end
end

namespace :monit do
  namespace :resque do
    task :restart do
      if fetch(:stage) == :production then
        on roles(:app) do
          %w[workers scheduler].each do |svc| 
            monit_do :restart, "showtime_resque_#{svc}"
          end

          ffmpeg_pids = capture(:pidof, 'ffmpeg', raise_on_non_zero_exit: false).strip.split(/\s+/)
          if ffmpeg_pids.empty? then
            %w[streaming recording].each do |svc|
              monit_do :restart, "showtime_resque_#{svc}"
            end
          end
        end
      end
    end
  end
end

after 'deploy:updated', 'monit:resque:restart'
