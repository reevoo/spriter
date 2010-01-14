$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), *%w[ .. lib ])))

require 'shoulda'
require 'spriter'

Spriter.assets_path = File.join(File.dirname(__FILE__), *%w[ fixtures images ])
Spriter.sprite_image_path = File.join(File.dirname(__FILE__), *%w[ temp sprites.png ])
Spriter.sprite_image_url = '/images/sprites.png'
