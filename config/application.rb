require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  # Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  Bundler.require(:default, :assets, Rails.env)
end

module Commonplace
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Enable the asset pipeline
    config.assets.enabled = true

    # Heroku...
    # config.assets.initialize_on_precompile = false

    # config.static_cache_control = "public, max-age=31536000"

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.1'

    config.assets.paths += [File.join(Rails.root, 'app', 'javascripts'),
                            File.join(Rails.root, 'app', 'stylesheets'),
                            File.join(Rails.root, 'app', 'templates'),
                            File.join(Rails.root, 'app', 'text'),
                            File.join(Rails.root, 'app', 'images'),
                            File.join(Rails.root, 'vendor', 'javascripts'),
                            File.join(Rails.root, 'vendor', 'images'),
                            File.join(Rails.root, 'vendor', 'stylesheets'),
                            File.join(Rails.root, 'lib', 'javascripts')
                           ]

    config.assets.precompile += ['main_page.js', 'group_page.js', 'inbox.js',
                                 'feed_page.js', 'invite_page.js',
                                 'registration_page.js', 'feed_registration.js',
                                 'sign_in.js', 'accounts.js']

    config.assets.precompile += ['feed_registration.css.sass', 'main_page.css.sass',
                                 'group_page.css.sass', 'feed_page.css.sass',
                                 'registration_page.css.sass', 'login_page.css.sass',
                                 'inbox.css.sass']

    config.generators do |g|
      g.orm :active_record
    end

    config.autoload_paths += %W( #{config.root}/mail #{config.root}/lib #{config.root}/**/ )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Set the logger
    # This makes Heroku logging with Unicorn work
    # config.logger = Logger.new(STDOUT)
  end
end
