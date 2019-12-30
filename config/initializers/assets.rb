# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.precompile += Rails.application.config.assets.precompile += %w( *.svg *.eot *.woff *.woff2 *.ttf *.jpg *.jpeg *.png *.gif)
Rails.application.config.assets.precompile << lambda { |path, fn|
  fn =~ %r{app/assets/javascripts/app} and ['.js'].include?(File.extname(path))
}
Rails.application.config.assets.precompile << lambda { |path, fn|
  fn =~ %r{app/assets/stylesheets/app} and ['.css','.scss'].include?(File.extname(path))
}

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
