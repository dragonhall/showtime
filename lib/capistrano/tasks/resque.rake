def monit_do(*args)
  on roles :app do
    execute :sudo, :monit, *args
  end
end

namespace :monit do
  namespace :resque do
    task :restart do
      on roles(:app) do
        %w[workers scheduler].each do |svc| 
          monit_do :restart, "showtime_resque_#{svc}"
        end

        ffmpeg_pids = capture(:pidof, 'ffmpeg').strip.split(/\s+/)
        if ffmpeg_pids.empty? then
          %w[streaming recording].each do |svc|
            monit_do :restart, "showtime_resque_#{svc}"
          end
        end
      end
    end
  end
end

after 'deploy:updated', 'monit:resque:restart'
