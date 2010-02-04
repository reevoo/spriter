require File.join(File.dirname(__FILE__), *%w[ test_helper ])

require 'rack/spriter'
require 'test/unit'
require 'mocha'

module Rails
  def self.root
    '/rails/root'
  end
end

class Rack::SpriterRailsTest < Test::Unit::TestCase

  context "a Rack::Spriter instance with no custom options" do
    setup do
      app = lambda{ true }
      @spriter = Rack::Spriter.new(app)
    end
    should "derive default options from Rails" do
      assert_equal '/rails/root/public/stylesheets', @spriter.default_options[:stylesheets_path]
      assert_equal '/rails/root/public/images/sprite_assets', @spriter.default_options[:assets_path]
      assert_equal '/rails/root/public/images/sprites.png', @spriter.default_options[:sprite_image_path]
      
    end
  end

end
