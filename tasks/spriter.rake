namespace :spriter
  desc "Generates CSS files and a sprite image from all .spriter files"
  task :generate do
    Spriter.assets_path = File.join(Rails.root, *%w[ public images sprite_assets ])
    Spriter.sprite_image_path = File.join(Rails.root, *%w[ public images sprites.png ])
    Spriter.sprite_image_url = '/images/sprites.png'

    paths = Dir.glob(File.join(Rails.root, 'public', 'stylesheets', '*.spriter'))
    Spriter.transform_files(*paths)
  end
end
