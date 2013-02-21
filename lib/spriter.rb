require 'mini_magick'

class Spriter
  class << self
    attr_accessor :assets_path
    attr_accessor :sprite_image_path
    attr_accessor :sprite_image_url

    def transform(*args)
      new.transform(*args)
    end

    def transform_files(*args)
      new.transform_files(*args)
    end

    def image_dimensions(path)
      dimensions = [0, 0]
      if path =~ /\.png$/
        dimensions = IO.read(path)[0x10..0x18].unpack('NN')
      elsif path =~ /\.gif$/
        dimensions = IO.read(path)[6..10].unpack('SS')
      end

      if dimensions.any?{|n| n.zero? }
        magick_image = MiniMagick::Image.from_file(path)
        dimensions = [ magick_image[:width], magick_image[:height] ]
      end

      dimensions
    end
  end

  attr_reader :images

  def initialize(assets_path = Spriter.assets_path, sprite_image_path = Spriter.sprite_image_path, sprite_image_url = Spriter.sprite_image_url)
    @assets_path, @sprite_image_path, @sprite_image_url = assets_path, sprite_image_path, sprite_image_url
    @images = []
    @y_offsets = {}
    @current_offset, @max_width = 0, 0
  end

  def transform(*inputs)
    previous_image_list = inputs.last.is_a?(Array) ? inputs.pop : []

    image_matcher = /([^a-z])-spriter-background:\s*([^;\}]+)([;\}])/
    new_css = inputs.inject([]) do |new_css, css|
      css = css.read if css.respond_to? :read
      new_css << css.gsub(image_matcher) do |matched|
        indent, image, terminator = $1, $2, $3
        image = image.strip.gsub(/(?:^['"]|['"]$)/, '')
        add_image(image)
        "#{indent}background: url(#{@sprite_image_url}) no-repeat 0 #{-y_offset(image)}#{y_offset(image) == 0 ? '' : 'px'}#{terminator} /* #{image} */"
      end
    end

    generate_sprite_image unless @images == previous_image_list

    if new_css.length == 1
      new_css.first
    else
      new_css
    end
  end

  def transform_files(*paths)
    files = paths.map{ |p| File.open(p, 'r') }
    generated_css = transform(*files)
    generated_css = [generated_css] unless generated_css.is_a? Array
    paths.map{ |p| p.sub(/\.spriter$/, '.css') }.each_with_index do |output_path, i|
      File.open(output_path, 'w'){ |f| f << generated_css[i] }
    end
  end

  def add_image(image)
    return if @images.include? image

    width, height = self.class.image_dimensions(File.join(@assets_path, image))

    @images << image
    @y_offsets[image] = @current_offset
    @current_offset += height
    @max_width = [@max_width, width].max
  end

  def y_offset(image)
    @y_offsets[image] or raise ArgumentError, "Unknown image (#{image})\nKnown images are: #{@images.join(', ')}"
  end

  def generate_sprite_image
    return unless @images.any?
    source_paths = @images.map{ |file| File.join(@assets_path, file) }
    system(*['convert', source_paths, '-gravity', 'West', '-background', '#FFFFFF00', '-append', @sprite_image_path].flatten) or raise "Failed to generate sprite"
  end
end
