class Administration < Sinatra::Base

  set :views, Rails.root.join("app", "administration")
  
  # Make sure the current user is an admin
  before do
    @account = env['warden'].user(:user)
    redirect "/" unless @account && @account.admin?
  end 

  # Show all the messages passing through CommonPlace
  get "/view_messages" do
    @messages = Message.find(:all, :order => "id desc", :limit => 50).sort { |x, y| y.created_at <=> x.created_at }
    erb :view_messages
  end

  # Export Community data as csvs
  get "/:community/export_csv" do
    if params[:community] == "global"
      send_file StatisticsAggregator.csv_statistics_globally, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=#{params[:community]}.csv"
    else
      send_file StatisticsAggregator.generate_statistics_csv_for_community(Community.find_by_slug(params[:community])), :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=#{params[:community]}.csv"
    end
  end

  # Show referrers that users enter during registration
  get "/show_referrers" do
    erb :show_referrers
  end

  # Show requests to bring CommonPlace to a town (created on the about page)
  get "/show_requests" do
    @requests = Request.all.sort{ |a,b| a.created_at <=> b.created_at }
    erb :show_requests
  end

  # Kickoff a job to generate CSVs
  get "/generate_csvs" do
    Resque.enqueue(StatisticsCsvGenerator)
    200
  end

  # List available CSVs to download, or regenerate them
  get "/download_csv" do
    @communities = Community.all.select { |c| Resque.redis.get("statistics:csv:#{c.slug}").present? }
    @date = Resque.redis.get("statistics:csv:meta:date")
  end

  # Become a user 
  #
  # Params: id - the user to become
  get "/become" do
    env['warden'].set_user(User.find(params[:id]), :scope => :user)
    redirect "/"
  end

end