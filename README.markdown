# Spriter #

[CSS sprites][1] are a simple way of combining lots of small images into a single large image and reducing the number of HTTP requests a web page has to make.  Spriter makes it easy to create and maintain CSS sprites in Ruby apps.

You just write some modified CSS rules in a `.spriter` file:

    span.icon {
      color: red;
      -spriter-background: 'example.png';
    }

And then run all your `.spriter` files through Spriter to get some `.css` files and a shared sprite image:

    span.icon {
      color: red;
      background: url(/images/sprites.png) no-repeat 0 -98px; /* example.png */
    }

The conversion can take place dynamically whenever the CSS files are requested using a handy [Rack][2] middleware (useful for development) or static files can be generated using a few lines of Ruby (as part of your deploy scripts, for example).

## Dependancies ##

You must have [Image Magick][3] installed, and the `convert` command must be in the path of the user or app that is using Spriter.

## Usage ##

### Middleware ###

Just add the `Rack::Spriter` middleware to your rack stack. For example, in a Rails app you would add this line to your `environment.rb`:

    config.middleware.use 'Rack::Spriter'

You can pass a hash of options to the middleware, using these keys:

* `:sprite_image_path` - the path to write the sprite image to (Rails default: `'RAILS_ROOT/public/images/sprites.png'`)
* `:sprite_image_url` - the URL of the sprite image that will be used in the generated CSS files (default: `'/images/sprites.png'`)
* `:stylesheets_url_pattern` - URLs matching this pattern will trigger the middleware (default: `/stylesheets\/(.+)\.css$/`)
* `:stylesheets_path` - the directory to look for .spriter files in (Rails default: `'RAILS_ROOT/pubic/stylesheets'`)
* `:assets_path` - the directory to look for source images in (Rails default: `'RAILS_ROOT/public/images/sprite_assets'`)

### Generating static CSS files ###

To generate static CSS files, you can pass an array of paths to `.spriter` files into the `transform_files` method. A `.css` equivalent for each `.spriter` file and a shared sprites image will be created.

The CSS files will be created in the same directories as the `.spriter` source files. The paths for the source images and generated sprite image should be set using the following options before calling `transform_files`:

* `Spriter.assets_path` - the directory to look for source images in
* `Spriter.sprite_image_path` - the path to write the sprite image to
* `Spriter.sprite_image_url` - the URL of the sprite image that will be used in the generated CSS files

For example:

    Spriter.assets_path = '/example_app/public/images/sprite_assets'
    Spriter.sprite_image_path = '/example_app/public/images/sprites.png'
    Spriter.sprite_image_url = '/images/sprites.png'
    
    paths = Dir.glob('/my/example/app/public/stylesheets/*.spriter').sort
    Spriter.transform_files(*paths)

## License ##

Copyright Revieworld Ltd. 2010

You may use, copy and redistribute this library under the same terms as [Ruby itself][4] or under the MIT license.

[1]: http://www.alistapart.com/articles/sprites/
[2]: http://rack.rubyforge.org/
[3]: http://www.imagemagick.org/
[4]: http://www.ruby-lang.org/en/LICENSE.txt
