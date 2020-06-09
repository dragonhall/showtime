# frozen_string_literal: true

namespace :deploy do
  after :compile_assets, :symlink_assets

  desc 'Create soft links for non-digested assets'
  task :symlink_assets do
    on release_roles(fetch(:assets_roles)) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'assets:soft_links'
        end
      end
    end
  end
end
