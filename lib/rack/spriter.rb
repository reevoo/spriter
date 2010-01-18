require 'spriter'

module Rack
  class Spriter

    File = ::File

    def initialize(app, options = {})
      @app = app
      ::Spriter.assets_path = options[:assets_path] || File.join(Rails.root, *%w[ public images sprite_assets ])
      ::Spriter.sprite_image_path = options[:sprite_image_path] || File.join(Rails.root, *%w[ public images sprites.png ])
      ::Spriter.sprite_image_url = options[:sprite_image_url] || '/images/sprites.png'
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
        generated_css($1)
      end
    end

    def generated_css(name)
      @generated_css ||= (
        paths = Dir.glob(File.join(Rails.root, 'public', 'stylesheets', '*.css.sprite'))
        names = paths.map{ |p| p =~ %r{stylesheets/(.+)\.css\.sprite$}; $1 }
        files = paths.map{ |p| File.new(p, 'r') }
        css = ::Spriter.transform(*files)
        css = [css] unless css.is_a? Array
        Hash[*names.zip(css).flatten]
      )
      @generated_css[name]
    end
  end
end
