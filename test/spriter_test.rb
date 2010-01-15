require File.join(File.dirname(__FILE__), *%w[ test_helper ])

class SpriterTest < Test::Unit::TestCase

  def setup
    Spriter.assets_path = File.join(File.dirname(__FILE__), *%w[ fixtures images ])
    Spriter.sprite_image_path = File.join(File.dirname(__FILE__), *%w[ temp sprites.png ])
    Spriter.sprite_image_url = '/images/sprites.png'
  end

  def teardown
    File.delete(Spriter.sprite_image_path) if File.exist? Spriter.sprite_image_path
  end

  context 'Spriter.image_dimensions' do
    should 'return the correct dimensions for an image' do
      width, height = Spriter.image_dimensions(File.join(File.dirname(__FILE__), *%w[ fixtures images green.png ]))
      assert_equal 50, width
      assert_equal 20, height
    end
  end

  context 'CSS with no -spriter rules' do
    setup do
      @css = <<-CSS
        body {
          font-family: 'Georgia', 'Times', serif;
          font-size: small;
          color: #f00;
        }
        p {
          margin: 0 0 1em 0;
          background-image: url(/my-spriter-images/badger.gif);
          border-radius: 10px;
          -webkit-border-radius: 10px;
          -moz-border-radius: 10px;
          -spriter-undefined: 0;
        }
      CSS

      @new_css = Spriter.transform(@css)
    end

    should 'not be changed at all' do
      assert_equal @css, @new_css
    end

    should 'not produce a sprite image' do
      assert_equal false, File.exist?(Spriter.sprite_image_path), 'Expected no sprite image file to be created'
    end
  end

  context 'CSS with spriter rules' do
    setup do
      @css = <<-CSS
        .green1 {
          width: 10px;
          -spriter-background: 'green.png';
          height: 20px;
        }
        .red {
          -spriter-background: 'red.png';
        }
        .green2 {
          -spriter-background: 'green.png';
        }
      CSS

      @new_css = Spriter.transform(@css)
    end

    should 'produce the expected CSS' do
      expected_css = <<-CSS
        .green1 {
          width: 10px;
          background: url(/images/sprites.png) 0 0; /* green.png */
          height: 20px;
        }
        .red {
          background: url(/images/sprites.png) 0 -20px; /* red.png */
        }
        .green2 {
          background: url(/images/sprites.png) 0 0; /* green.png */
        }
      CSS
      assert_equal expected_css, @new_css
    end

    should 'generate a sprite image with the expected dimensions' do
      assert File.exist?(Spriter.sprite_image_path), 'Expected a sprite image file to be created'
      assert_equal [50, 70], Spriter.image_dimensions(Spriter.sprite_image_path)
    end
  end

end
