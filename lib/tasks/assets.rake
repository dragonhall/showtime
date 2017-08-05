namespace :assets do
  desc 'Create soft links for non-digested assets'
  task soft_links: 'assets:precompile' do
    # assets = Dir.glob(Rails.root.join('public/assets/**/*'))
    # manifest_path = assets.find { |f| f =~ /(manifest)(-{1}[a-z0-9]{32}\.{1}){1}/ }
    manifest_path = Dir.glob(Rails.root.join('public/assets/**/.sprockets-manifest-*.json')).first

    if manifest_path
      manifest_data = JSON.load(File.new(manifest_path))
      assets_data = manifest_data['assets'].each do |asset_name, file_name|
        file_path = Rails.root.join('public/assets', file_name).to_s
        asset_path = Rails.root.join('public/assets', asset_name).to_s
        FileUtils.ln_s(file_path, asset_path, force: true)
      end
    end
  end
end
