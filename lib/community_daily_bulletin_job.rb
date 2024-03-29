require 'rubygems'
require 'barometer'

class CommunityDailyBulletinJob
  include MailUrls
  @queue = :community_daily_bulletin

  def self.url(path)
    if path.start_with?("http")
      path
    else
      if Rails.env.development?
        "http://localhost:5000" + path
      else
        "https://www.ourcommonplace.com" + path
      end
    end
  end

  def self.asset_url(path)
    if path.start_with?("http")
      path
    else
      "https://s3.amazonaws.com/commonplace-mail-assets-production/#{path}"
    end
  end

  def self.community_url(community, path)
    CommunityDailyBulletinJob.url("/#{community.slug}#{path}")
  end

  def self.show_announcement_url(community, id)
    CommunityDailyBulletinJob.community_url(community, "/show/announcements/#{id}")
  end

  def self.show_post_url(community, id)
    CommunityDailyBulletinJob.community_url(community, "/show/posts/#{id}")
  end

  def self.show_group_post_url(community, id)
    CommunityDailyBulletinJob.community_url(community, "/show/group_posts/#{id}")
  end

  def self.show_transaction_url(community, id)
    CommunityDailyBulletinJob.community_url(community, "/show/transactions/#{id}")
  end

  def self.show_event_url(community, id)
    CommunityDailyBulletinJob.community_url(community, "/show/events/#{id}")
  end

  def self.message_user_url(community, id)
    CommunityDailyBulletinJob.community_url(community, "/message/users/#{id}")
  end

  def self.show_user_url(community, id)
    CommunityDailyBulletinJob.community_url(community, "/show/users/#{id}")
  end

  def self.perform(community_id, date)
    kickoff = KickOff.new
    community = Community.find(community_id)

    date = DateTime.parse(date)
    yesterday = date.advance(:days => -1)

    posts = community.posts.between(yesterday, date).map do |post|
      Serializer::serialize(post).tap do |post|
        post['replies'].each do |reply|
          reply['published_at'] = reply['published_at'].strftime("%l:%M%P")
          reply['avatar_url'] = CommunityDailyBulletinJob.asset_url(reply['avatar_url'])
          reply['author_url'] = CommunityDailyBulletinJob.show_user_url(community, reply['author_id'])
        end
        post['avatar_url'] = CommunityDailyBulletinJob.asset_url(post['avatar_url'])
        post['url'] = CommunityDailyBulletinJob.show_post_url(community, post['id'])
        post['new_message_url'] = CommunityDailyBulletinJob.message_user_url(community, post['user_id'])
        post['author_url'] = CommunityDailyBulletinJob.show_user_url(community, post['user_id'])
      end
    end

    group_posts = community.group_posts.between(yesterday, date).map do |group_post|
      Serializer::serialize(group_post).tap do |group_post|
        group_post['replies'].each do |reply|
          reply['published_at'] = reply['published_at'].strftime("%l:%M%P")
          reply['avatar_url'] = CommunityDailyBulletinJob.asset_url(reply['avatar_url'])
          reply['author_url'] = CommunityDailyBulletinJob.show_user_url(community, reply['author_id'])
        end
        group_post['avatar_url'] = CommunityDailyBulletinJob.asset_url(group_post['avatar_url'])
        group_post['url'] = CommunityDailyBulletinJob.show_group_post_url(community, group_post['id'])
        group_post['new_message_url'] = CommunityDailyBulletinJob.message_user_url(community, group_post['user_id'])
        group_post['author_url'] = CommunityDailyBulletinJob.show_user_url(community, group_post['user_id'])
      end
    end

    transactions = community.transactions.between(yesterday, date).map do |trans|
      Serializer::serialize(trans).tap do |trans|
        trans['replies'].each do |reply|
          reply['published_at'] = reply['published_at'].strftime("%l:%M%P")
          reply['avatar_url'] = CommunityDailyBulletinJob.asset_url(reply['avatar_url'])
          reply['author_url'] = CommunityDailyBulletinJob.show_user_url(community, reply['author_id'])
        end
        trans['avatar_url'] = CommunityDailyBulletinJob.asset_url(trans['avatar_url'])
        trans['url'] = CommunityDailyBulletinJob.show_transaction_url(community, trans['id'])
        trans['new_message_url'] = CommunityDailyBulletinJob.message_user_url(community, trans['user_id'])
        trans['author_url'] = CommunityDailyBulletinJob.show_user_url(community, trans['user_id'])
        if trans['price'] == 0
          trans['price'] = "Free"
        else
          trans['price'] = "$%.2f" % (trans['price']/100).to_f
        end
      end
    end

    announcements = community.announcements.between(yesterday, date).map do |announcement|
      Serializer::serialize(announcement).tap do |announcement|
        announcement['replies'].each {|reply|
          reply['published_at'] = reply['published_at'].strftime("%l:%M%P")
          reply['avatar_url'] = CommunityDailyBulletinJob.asset_url(reply['avatar_url'])
          reply['author_url'] = CommunityDailyBulletinJob.show_user_url(community, reply['author_id'])
        }
        announcement['avatar_url'] = CommunityDailyBulletinJob.asset_url(announcement['avatar_url'])
        announcement['url'] = CommunityDailyBulletinJob.show_announcement_url(community, announcement['id'])
        announcement['author_url'] = CommunityDailyBulletinJob.show_user_url(community, announcement['user_id'])
      end
    end

    events = community.events.between(date, date.advance(:weeks => 1)).map do |event|
      Serializer::serialize(event).tap do |event|
        event['replies'].each {|reply|
          reply['published_at'] = reply['published_at'].strftime("%l:%M%P")
          reply['avatar_url'] = CommunityDailyBulletinJob.asset_url(reply['avatar_url'])
          reply['author_url'] = CommunityDailyBulletinJob.show_user_url(community, reply['author_id'])
        }
        event["short_month"] = event['occurs_on'].strftime("%b")
        event["day"] = event['occurs_on'].strftime("%d")
        event['url'] = CommunityDailyBulletinJob.show_event_url(community, event['id'])
        event['author_url'] = CommunityDailyBulletinJob.community_url(community, event['links']['author'])
      end
    end

    ad = community.ads.where("? between ads.start_date and ads.end_date", date).first
    if ad.present?
      image = ad.image.image_url
    end

    begin
      barometer = Barometer.new(community.zip_code)
      weather = barometer.measure
    rescue => ex
      binding.pry
      raise "Problem with barometer for #{community.name}"
    end

    community.users.receives_daily_bulletin.each do |user|
      begin
        parameters = {
          user_id: user.id,
          date: date,
          posts: posts,
          group_posts: group_posts,
          transactions: transactions,
          announcements: announcements,
          events: events,
          weather: weather.default,
          ad: ad,
          image: image
        }
        kickoff.deliver_daily_bulletin(parameters[:user_id], parameters[:date], parameters[:posts], parameters[:group_posts], parameters[:transactions], parameters[:announcements], parameters[:events], parameters[:weather], parameters[:ad], parameters[:image])
      rescue => ex
        Airbrake.notify_or_ignore(
          :error_class   => "Error Sending Daily Bulletin",
          :error_message => "Could not send to #{user.email}: #{ex.message}",
          :parameters    => parameters
        )
      end
    end
  end
end
