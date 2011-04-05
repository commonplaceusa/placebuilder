class Feed < ActiveRecord::Base
  
  acts_as_taggable_on :tags

  validates_presence_of :name, :community
  validates_presence_of :about, :if => lambda { |f| f.user_id }

  validates_uniqueness_of :slug, :scope => :community_id, :allow_nil => true

  before_create :generate_slug

  belongs_to :community
  belongs_to :user

  has_many :events, :dependent => :destroy, :as => :owner, :include => :replies

  has_many :announcements, :dependent => :destroy, :as => :owner, :include => :replies

  has_many :subscriptions, :dependent => :destroy
  has_many :subscribers, :through => :subscriptions, :source => :user

  has_attached_file(:avatar,                    
                    :styles => { 
                      :thumb => "100x100^", 
                      :normal => "120x120^",
                      :large => "200x200^"
                    },
                    :default_url => "/avatars/missing.png", 
                    :url => "/system/feeds/:id/avatar/:style.:extension",
                    :path => ":rails_root/public/system/feeds/:id/avatar/:style.:extension")

  def website=(string)
    if string.present? && !(string =~ /^https?:\/\//)
      super("http://" + string)
    else
      super(string)
    end
  end
  
  def avatar_url(style_name = nil)
    self.avatar.url(style_name || self.avatar.default_style)
  end


  def wire
    (self.announcements + self.events).sort_by do |item|
      time = case item
             when Event then item.start_datetime
             when Announcement then item.created_at
             end 
      (time - Time.now).abs
    end
  end

  def is_news
    self.kind == 4
  end
  
  def self.kinds
    feed_kinds = ActiveSupport::OrderedHash.new
    feed_kinds["A community group"] = 1
    feed_kinds["A business"] = 2
    feed_kinds["A municipal entity"] = 3
    feed_kinds["A newspaper, news service, or news blog"] = 4
    feed_kinds["Other"] = 5
    feed_kinds
  end

  private

  def generate_slug
    string = self.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n, '').to_s
    string.gsub!(/[']+/, '')
    string.gsub!(/\W+/, ' ')
    string.strip!
    string.downcase!
    string.gsub!(' ', '-')

    if Feed.exists?(:slug => string, :community_id => self.community_id)
      self.slug = nil
    else
      self.slug = string
    end
  end
end
