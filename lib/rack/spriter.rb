require 'spriter'

module Rack
  class Spriter

    File = ::File

    def initialize(app)
      @app = app
      ::Spriter.assets_path = File.join(Rails.root, *%w[ public images sprite_assets ])
      ::Spriter.sprite_image_path = File.join(Rails.root, *%w[ public images sprites.png ])
      ::Spriter.sprite_image_url = '/images/sprites.png'
    end

    def call(env)
      if css = generate_css(env)
        return [200, {"Content-Type" => "text/css", "Cache-Control" => "private"}, [css]]
      else
        @app.call(env)
      end
    end
    
    private
    def generate_css(env)
      if Rack::Request.new(env).path =~ %r{stylesheets\/(.+)\.css$}
        spriter_css_path = File.join(Rails.root, 'public', 'stylesheets', "#{$1}.css.sprite")
        if File.exists? spriter_css_path
          ::Spriter.transform(File.read(spriter_css_path))
        end
      end
    end
  end
end
