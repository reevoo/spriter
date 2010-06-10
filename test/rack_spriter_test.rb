require File.join(File.dirname(__FILE__), *%w[ test_helper ])

require 'rack/spriter'
require 'test/unit'
require 'rack/test'
require 'mocha'

class Rack::SpriterTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    app = lambda{|env| [200, {"Content-Type" => "text/plain"}, ["all is good"]]}
    stylesheets_path = File.join(File.dirname(__FILE__), *%w[ temp public stylesheets ])
    assets_path = File.join(File.dirname(__FILE__), *%w[ fixtures images ])
    sprite_image_path = File.join(File.dirname(__FILE__), *%w[ temp sprites.png ])
    Rack::Spriter.new(app, :stylesheets_path => stylesheets_path, :assets_path => assets_path, :sprite_image_path => sprite_image_path)
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

  context "when some css is requested from a nested folder" do
    setup do
      public_path = File.join(File.dirname(__FILE__), 'temp', 'public')
      stylesheets_path = File.join(public_path, 'stylesheets')
      nested_path = File.join(stylesheets_path, 'foo')
      [ public_path, stylesheets_path, nested_path ].each { |path| Dir.mkdir(path) unless File.exist? path }

      @sprite_path = File.join(nested_path, 'screen.spriter')

      File.open(@sprite_path, 'w') do |f|
        f << ".test { -spriter-background: 'red.png'; }"
      end

      get '/stylesheets/foo/screen.css'
    end

    should "render sprited css" do
      assert_equal ".test { background: url(/images/sprites.png) no-repeat 0 0; /* red.png */ }", last_response.body
    end
  end

  context "when some css is requested" do
    setup do
      public_path = File.join(File.dirname(__FILE__), 'temp', 'public')
      stylesheets_path = File.join(public_path, 'stylesheets')
      [ public_path, stylesheets_path ].each { |path| Dir.mkdir(path) unless File.exist? path }

      @sprite_path = File.join(stylesheets_path, 'screen.spriter')
      File.open(@sprite_path, 'w') do |f|
        f << ".test { -spriter-background: 'red.png'; }"
      end

      get '/stylesheets/screen.css'
    end
    should "render sprited css" do
      assert_equal ".test { background: url(/images/sprites.png) no-repeat 0 0; /* red.png */ }", last_response.body
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

  context "when some css is requested and there is no spriter file" do
    setup{ get '/stylesheets/nothing.css' }
    should "delegate" do
      assert_equal 200, last_response.status
      assert_equal "all is good", last_response.body
    end
  end
end
