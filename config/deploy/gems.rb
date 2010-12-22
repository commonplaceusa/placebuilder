namespace :gems do
  task :install, :roles => :app do
    # For when we use bundler
    run "cd #{current_path} && bundle install --path vendor --without test development"
  end
end
after "deploy:update_code", "gems:install"
