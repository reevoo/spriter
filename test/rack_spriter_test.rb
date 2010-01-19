require File.join(File.dirname(__FILE__), *%w[ test_helper ])

require 'rack/spriter'
require 'test/unit'
require 'rack/test'
require 'mocha'

module Rails
  def self.root
    File.join(File.dirname(__FILE__), *%w[ temp ])
  end
end


class Rack::SpriterTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    app = lambda{|env| [200, {"Content-Type" => "text/plain"}, ["all is good"]]}
    assets_path = File.join(File.dirname(__FILE__), *%w[ fixtures images ])
    sprite_image_path = File.join(File.dirname(__FILE__), *%w[ temp sprites.png ])
    Rack::Spriter.new(app, :assets_path => assets_path, :sprite_image_path => sprite_image_path)
  end

  context "when css isn't being requested" do
    setup do
      get '/some/other/path'
    end
    should "delegate" do
      assert_equal 200, last_response.status
      assert_equal "all is good", last_response.body
    end
  end

  context "when some css is requested" do
    setup do
      [
        File.join(Rails.root, 'public'),
        File.join(Rails.root, 'public', 'stylesheets')
      ].each { |path| Dir.mkdir(path) unless File.exist? path }

      @sprite_path = File.join(Rails.root, 'public', 'stylesheets', 'screen.spriter')
      File.open(@sprite_path, 'w') do |f|
        f << ".test { -spriter-background: 'red.png'; }"
      end

      get '/stylesheets/screen.css'
    end
    should "render sprited css" do
      assert_equal ".test { background: url(/images/sprites.png) 0 0; /* red.png */ }", last_response.body
    end

    context "when it is requested again" do
      setup{ get '/stylesheets/screen.css' }
      before_should 'not generate it again' do
        Spriter.expects(:transform).never
      end
    end

    context "when the spriter file is modified and it is requested again" do
      setup do
        File.any_instance.stubs(:mtime).returns(Time.now + 10)
        get '/stylesheets/screen.css'
      end
      before_should 'generate it again' do
        Spriter.expects(:transform).once
      end
    end
  end
end
