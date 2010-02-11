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
          background: url(/images/sprites.png) no-repeat 0 0; /* green.png */
          height: 20px;
        }
        .red {
          background: url(/images/sprites.png) no-repeat 0 -20px; /* red.png */
        }
        .green2 {
          background: url(/images/sprites.png) no-repeat 0 0; /* green.png */
        }
      CSS
      assert_equal expected_css, @new_css
    end

    should 'generate a sprite image with the expected dimensions' do
      assert File.exist?(Spriter.sprite_image_path), 'Expected a sprite image file to be created'
      assert_equal [50, 70], Spriter.image_dimensions(Spriter.sprite_image_path)
    end
  end

  context 'an IO object' do
    setup do
      css_io = StringIO.new('.test { -spriter-background: "red.png"; }')
      @new_css = Spriter.transform(css_io)
    end
    should 'produce the expected CSS' do
      assert_equal '.test { background: url(/images/sprites.png) no-repeat 0 0; /* red.png */ }', @new_css
    end
  end

  context 'a spriter rule terminated by a closing brace' do
    setup { @new_css = Spriter.transform('.test { -spriter-background: "red.png" }') }
    should 'produce the expected CSS' do
      assert_equal '.test { background: url(/images/sprites.png) no-repeat 0 0} /* red.png */', @new_css
    end
  end

  context 'multiple CSS files with no overlapping rules' do
    setup do
      css1 = ".test1 { -spriter-background: 'red.png'; }"
      css2 = ".test2 { -spriter-background: 'green.png'; }"
      @new_css = Spriter.transform(css1, css2)
    end
    should 'produce the expected CSS' do
      assert_equal 2, @new_css.length
      assert_equal ".test1 { background: url(/images/sprites.png) no-repeat 0 0; /* red.png */ }", @new_css.first
      assert_equal ".test2 { background: url(/images/sprites.png) no-repeat 0 -50px; /* green.png */ }", @new_css.last
    end
    should 'produce a single sprite image with the expected dimensions' do
      assert File.exist?(Spriter.sprite_image_path), 'Expected a sprite image file to be created'
      assert_equal [50, 70], Spriter.image_dimensions(Spriter.sprite_image_path)
    end
  end

  context 'multiple CSS files with overlapping rules' do
    setup do
      css1 = ".test1 { -spriter-background: 'red.png'; }\n.test2 { -spriter-background: 'green.png'; }"
      css2 = ".test3 { -spriter-background: 'red.png'; }\n.test4 { -spriter-background: 'green.png'; }"
      @new_css = Spriter.transform(css1, css2)
    end
    should 'use the same background positions for the images' do
      assert_equal ".test1 { background: url(/images/sprites.png) no-repeat 0 0; /* red.png */ }\n.test2 { background: url(/images/sprites.png) no-repeat 0 -50px; /* green.png */ }", @new_css.first
      assert_equal ".test3 { background: url(/images/sprites.png) no-repeat 0 0; /* red.png */ }\n.test4 { background: url(/images/sprites.png) no-repeat 0 -50px; /* green.png */ }", @new_css.last
    end
  end

  context 'converting one .spriter file' do
    setup do
      @first_css_path = File.join(File.dirname(__FILE__), 'temp/first.css')

      @first_sprite_path = @first_css_path.sub(/\.css$/, '.spriter')

      File.open(@first_sprite_path, 'w'){ |f| f << ".test1 { -spriter-background: 'red.png'; }" }

      @returned = Spriter.transform_files(@first_sprite_path)
    end

    teardown do
      files = Dir.glob(File.join(File.dirname(__FILE__), 'temp/*.{css,spriter}'))
      File.delete(*files)
    end

    should 'write the CSS to the files' do
      assert_equal ".test1 { background: url(/images/sprites.png) no-repeat 0 0; /* red.png */ }", File.read(@first_css_path)
    end
  end

  context 'converting some .spriter files' do
    setup do
      @first_css_path = File.join(File.dirname(__FILE__), 'temp/first.css')
      @second_css_path = File.join(File.dirname(__FILE__), 'temp/second.css')

      @first_sprite_path = @first_css_path.sub(/\.css$/, '.spriter')
      @second_sprite_path = @second_css_path.sub(/\.css$/, '.spriter')

      File.open(@first_sprite_path, 'w'){ |f| f << ".test1 { -spriter-background: 'red.png'; }" }
      File.open(@second_sprite_path, 'w'){ |f| f << ".test2 { -spriter-background: 'green.png'; }" }

      @returned = Spriter.transform_files(@first_sprite_path, @second_sprite_path)
    end

    teardown do
      files = Dir.glob(File.join(File.dirname(__FILE__), 'temp/*.{css,spriter}'))
      File.delete(*files)
    end

    should 'produce corresponding set of .css files' do
      assert File.exist?(@first_css_path)
      assert File.exist?(@second_css_path)
    end
    should 'write the CSS to the files' do
      assert_equal ".test1 { background: url(/images/sprites.png) no-repeat 0 0; /* red.png */ }", File.read(@first_css_path)
      assert_equal ".test2 { background: url(/images/sprites.png) no-repeat 0 -50px; /* green.png */ }", File.read(@second_css_path)
    end
    should 'produce a single sprite image with the expected dimensions' do
      assert File.exist?(Spriter.sprite_image_path), 'Expected a sprite image file to be created'
      assert_equal [50, 70], Spriter.image_dimensions(Spriter.sprite_image_path)
    end
    should 'return the output paths' do
      assert_equal [@first_css_path, @second_css_path], @returned
    end
  end

end
