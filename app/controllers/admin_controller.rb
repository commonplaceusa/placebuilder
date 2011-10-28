class AdminController < ApplicationController

  before_filter :verify_admin
  def verify_admin
    unless current_user.admin
      redirect_to root_url
    end
  end

  def view_messages
    @messages = Message.find(:all, :order => "id desc", :limit => 50).sort { |x, y| y.created_at <=> x.created_at }
    render :layout => false
  end


  def overview
    @communities = ActiveSupport::JSON.decode(Resque.redis.get "statistics:community")
    @overall_statistics = ActiveSupport::JSON.decode(Resque.redis.get "statistics:overall")
    @historical_statistics = StatisticsAggregator.historical_statistics
    render :layout => nil
  end

  def clipboard
    require 'uuid'
    UUID.state_file = false
    uuid = UUID.new
    if params[:registrants].present?
      entries = params[:registrants].split("\n")
      email_addresses_registered = []
      entries.each do |e|
        entry = e.split(';')
        name = entry[0]
        email = entry[1]
        address = entry[2]
        half_user = HalfUser.new(:full_name => name, :email => email, :street_address => address, :community => Community.find(params[:clipboard_community]), :single_access_token => uuid.generate)
        if half_user.save
          email_addresses_registered << email
          kickoff.deliver_clipboard_welcome(half_user)
        end
      end
      flash[:notice] = "Registered #{email_addresses_registered.count} users: #{email_addresses_registered.join(', ')}"
    end
  end

  def export_csv
    csv = "Date,Users,Posts,Events,Announcements"
    today = DateTime.now
    slug = params[:community]
    community = Community.find_by_slug(slug)
    launch = community.users.sort{ |a,b| a.created_at <=> b.created_at }.first.created_at.to_date
    launch.upto(today).each do |day|
      csv = "#{csv}\n#{day},#{community.users.between(launch.to_datetime,day.to_datetime).count},#{community.posts.between(launch.to_datetime,day.to_datetime).count},#{community.events.between(launch.to_datetime,day.to_datetime).count},#{community.announcements.between(launch.to_datetime,day.to_datetime).count}"
    end

    send_data csv, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=#{slug}.csv"
  end

  def show_referrers ; end
  def map ; end
end
