require "bundler/capistrano"
set :stages,        %w(canvasprod canvastest)
set :default_stage, "production"
require "capistrano/ext/multistage"

set :application,   "canvas"
set :repository,    "git://github.com/grahamb/canvas-lms.git"
set :scm,           :git
set :user,          "canvasuser"
set :branch,        "dev"
set :deploy_via,    :remote_cache
set :deploy_to,     "/var/rails/canvas"
set :use_sudo,      false
set :deploy_env,    "production"
set :bundle_dir,    "/opt/ruby-enterprise-1.8.7-2012.02/lib/ruby/gems/1.8"
set :bundle_flags,  "--deployment"

ssh_options[:forward_agent] = true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa_canvas")]

namespace :deploy do
	task :start do ; end
	task :stop do ; end
	desc 'Signal Passenger to restart the application.'
 	task :restart, :roles => :app, :except => { :no_release => true } do
		# run "touch #{release_path}/tmp/restart.txt"
    run "sudo /etc/init.d/httpd restart"
	end
end

namespace :canvas do

    desc "Create symlink for files folder to mount point"
    task :symlink_canvasfiles do
        target = "mnt/data"
        run "mkdir -p #{latest_release}/mnt/data && ln -s /mnt/data/canvasfiles #{latest_release}/#{target}/canvasfiles"
    end

    desc "Copy config files from /mnt/data/canvasconfig/config"
    task :copy_config do
      run "sudo /etc/init.d/canvasconfig start"
    end

    desc "Compile static assets"
    task :compile_assets, :on_error => :continue do
      # On remote: bundle exec rake canvas:compile_assets
      run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} canvas:compile_assets --quiet"
      run "cd #{latest_release} && chown -R canvasuser:canvasuser ."
    end

    desc "Load new notification types"
    task :load_notifications, :roles => :db, :only => { :primary => true } do
      # On remote: RAILS_ENV=production bundle exec rake db:load_notifications
      run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} db:load_notifications --quiet"
    end

    desc "Restart delayed jobs workers"
    task :restart_jobs, :on_error => :continue do
      run "/etc/init.d/canvas_init restart"
    end

    desc "Post-update commands"
    task :update_remote do
      copy_config
      deploy.migrate
      load_notifications
      restart_jobs
    end

end

after(:deploy, "deploy:cleanup")
before("deploy:restart", "canvas:symlink_canvasfiles")
before("deploy:restart", "canvas:compile_assets")
before("deploy:restart", "canvas:update_remote")


