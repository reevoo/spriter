require File.join(File.dirname(__FILE__), *%w[ test_helper ])

require 'rack/spriter'
require 'test/unit'
require 'rack/test'
require 'mocha'

module Rails
  def self.root
    ''
  end
end


class Rack::SpriterTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Rack::Spriter.new(lambda{|env| [200, {"Content-Type" => "text/plain"}, ["all is good"]]})
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
      ::Spriter.stubs(:transform).returns('some sweet css')
      File.stubs(:read).with(File.join(Rails.root, 'public', 'stylesheets', "screen.css.sprite")).returns('some css')
      File.stubs(:exists?).with(File.join(Rails.root, 'public', 'stylesheets', "screen.css.sprite")).returns(true)
      get '/stylesheets/screen.css'
    end
    should "render sprited css" do
      assert_equal 'some sweet css', last_response.body
    end
  end
end
