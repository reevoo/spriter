desc "Generate all the CSS and images"
task :generate do
  Spriter.assets_path = File.join(Rails.root, *%w[ public images sprite_assets ])
  Spriter.sprite_image_path = File.join(Rails.root, *%w[ public images sprites.png ])
  Spriter.sprite_image_url = '/images/sprites.png'

  paths = Dir.glob(File.join(Rails.root, 'public', 'stylesheets', '*.css.sprite'))
  Spriter.transform_files(*paths)
end
