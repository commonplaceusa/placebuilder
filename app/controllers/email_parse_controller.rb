class EmailParseController < ApplicationController
  
  protect_from_forgery :only => []
  
  before_filter :validate_email
  
  def validate_email
    params[:envelope][:from].present? && !params[:envelope][:from].include?("<>") && !params[:envelope][:from].include?("< >")
  end
  
  def to
    TMail::Address.parse(params[:to]).spec.match(/[A-Za-z0-9]*/)[0]
  end
  
  def process
    if Feed.find_by_slug(to)
      feed_announcements
    elsif Neighborhood.find_by_name(to)
      posts_new
    elsif to == "announce"
      announcement_new
    else
      type = to.match(/\+/)[1]
      puts type
      sleep(10)
      if type == "message"
        messages
      elsif type == "post"
        posts
      elsif type == "event"
        events
      elsif type == "announcement"
        announcements
      end
    end
  end
  
  def messages
    user = User.find_by_email(TMail::Address.parse(params[:from]).spec)
    post = Message.find_by_long_id(TMail::Address.parse(params[:to]).spec.match(/[A-Za-z0-9]*/)[0])
    if user && post
      text = EmailParseController.strip_email_body(params[:text])
      
      reply = Reply.create(:body => text,
                   :repliable => post,
                   :user => user)
      NotificationsMailer.deliver_message_reply(reply.id)
    end
    
    render :nothing => true
  end
  
  def unpublished
    @user = User.find_by_email(TMail::Address.parse(params[:from]).spec)
    if @user
      # lists my unpublished posts
      @posts = @user.posts.reject {|k,v| k.published == true}
      if @posts.count >= 1
        NotificationsMailer.deliver_unpublished_posts_report
      end
    end
  end
  
  def posts_new
    user = User.find_by_email(TMail::Address.parse(params[:from]).spec)
    if user
      p = Post.create!(:body => params[:text], :user => user, :subject => params[:subject], :community => user.community, :published => false)
      NotificationsMailer.deliver_neighborhood_post_confirmation(user.neighborhood.id,p.id)
    else
      NotificationsMailer.deliver_neighborhood_post_failure(user.id,user.neighborhood.id)
    end
  end
  
  def posts
    user = User.find_by_email(TMail::Address.parse(params[:from]).spec)
    post = Post.find_by_long_id(TMail::Address.parse(params[:to]).spec.match(/[A-Za-z0-9]*/)[0])
    if user && post
      text = EmailParseController.strip_email_body(params[:text])
      
      reply = Reply.create(:body => text,
                   :repliable => post,
                   :user => user)
      NotificationsMailer.deliver_post_reply(reply.id)
    end
    
    render :nothing => true
  end
  
  def events
    user = User.find_by_email(TMail::Address.parse(params[:from]).spec)
    post = Event.find_by_long_id(TMail::Address.parse(params[:to]).spec.match(/[A-Za-z0-9]*/)[0])
    if user && post
      text = EmailParseController.strip_email_body(params[:text])
      
      reply = Reply.create(:body => text,
                   :repliable => post,
                   :user => user)
      NotificationsMailer.deliver_event_reply(reply.id)
    end
    
    render :nothing => true
  end
  
  def feed_announcements
    user = User.find_by_email(TMail::Address.parse(params[:from]).spec)
    feed = Feed.find_by_slug(TMail::Address.parse(params[:to]).spec.match(/[A-Za-z0-9]*/)[0])
    if user && feed && feed.owner_id == user.id
      text = EmailParseController.strip_email_body(params[:text])
      announcement = Announcement.create!(:subject => params[:subject], :body => text, :private => false, :feed => feed, :community => feed.community)
      NotificationsMailer.deliver_feed_announcement_confirmation(feed.id,announcement.id)
    else
      NotificationsMailer.deliver_feed_announcement_failure(feed.id,feed.community.id)
    end
    
    render :nothing => true
  end
    
  
  def announcements
    user = User.find_by_email(TMail::Address.parse(params[:from]).spec)
    post = Announcement.find_by_long_id(TMail::Address.parse(params[:to]).spec.match(/[A-Za-z0-9]*/)[0])
    if user && post
      text = EmailParseController.strip_email_body(params[:text])
      
      reply = Reply.create(:body => text,
                   :repliable => post,
                   :user => user)
      NotificationsMailer.deliver_announcement_reply(reply.id)
    end
    
    render :nothing => true
  end
  
  def announcement_new
    
  end


  def self.strip_email_body(text)
    text.split(%r{(^-- \n) # match standard signature
                 |(^--\n) # match non-stantard signature
                 |(^-----Original\ Message-----) # Outlook
                 |(^----- Original\ Message -----) # Outlook
                 |(^________________________________) # Outlook
                 |(-*\ ?Original\ Message\ ?-*) # Generic
                 |(^On.*wrote:) # OS X Mail.app
                 |(^From:\ ) # Outlook and some others
                 |(^Sent\ from) # iPhone, Blackberry
                 |(^In\ a\ message\ dated.*,)
                 }x).first
  end
  


end
