class KickOff
  
  def initialize(queuer = Resque)
    @queuer = queuer
  end
 
  def deliver_post(post)
    send_post_to_neighborhood(post, post.neighborhood)
  end


  def deliver_announcement(post)
    # We're only actually delivering anything if the poster is a feed
    return if !post.owner.is_a? Feed

    # We're delivering to live subscribers of the feed
    recipient_ids = post.owner.live_subscribers.map &:id

    # Send it
    recipient_ids.each do |user_id|
      enqueue(AnnouncementNotification, post.id, user_id)
    end
  end

  
  def deliver_reply(reply)
    # We're delivering a reply to the author of the repliable
    repliable_ids = [reply.repliable.user_id]

    # As well as anyone else who replied
    repliable_ids += reply.repliable.replies.map &:user_id
    
    # But not the author of the current reply
    repliable_ids.delete(reply.user_id)

    # Only send once to each person
    repliable_ids.uniq!

    # Send it
    repliable_ids.each do |user_id|
      enqueue(ReplyNotification, reply.id, user_id)
    end
  end

  
  def deliver_feed_invite(emails, feed)
    # Given some emails 
    recipients = Array(emails) # it's definitely an array now

    # That don't already exist in the system
    
    recipients.reject! do |email| 
      User.exists?(:email => Mail::Address.new(email).address) 
    end

    # Send invites
    recipients.each do |email|
      enqueue(FeedInvitation, email, feed.id)
    end
  end

  def deliver_n_feed_subscribers_notification(feed_id)
    enqueue(NSubscribersFeedNotification, feed_id)
  end

  
  def deliver_group_post(post)
    # We're delivering a post to subscribers of the group
    recipients = post.group.live_subscribers.map(&:id)

    # Who aren't the poster
    recipients.delete(post.user_id)

    # Send it
    recipients.each do |user_id|
      enqueue(GroupPostNotification, post.id, user_id)
    end
  end

  
  def deliver_user_message(message)
    enqueue(MessageNotification, message.id, message.messagable_id)
  end


  def deliver_post_to_community(post)
    # Uplifting a post (sending it to whole community)
    community = post.community
    
    neighborhoods = community.neighborhoods

    # Its already been sent to it's neighborhood, don't do it again
    neighborhoods.delete(post.neighborhood)

    neighborhoods.each do |neighborhood|
      send_post_to_neighborhood(post, neighborhood)
    end
  end


  def deliver_clipboard_welcome(half_user)
    enqueue(ClipboardWelcome, half_user.id)
  end


  def deliver_user_invite(emails, from_user, message = nil)
    # emails is an array
    emails = Array(emails)

    emails.reject! do |email| 
      User.exists?(:email => Mail::Address.new(email).address) 
    end

    emails.each do |email|
      enqueue(Invitation, email, from_user.id, message)
    end
  end

  
  def deliver_post_confirmation(post)
    enqueue(PostConfirmation, post.id)
  end

  
  def deliver_announcement_confirmation(post)
    enqueue(AnnouncementConfirmation, post.id)
  end

  
  def deliver_feed_permission_warning(user, feed)
    enqueue(NoFeedPermission, user.id, feed.id)
  end


  def deliver_unknown_address_warning(user)
    enqueue(UnknownAddress, user.id)
  end

  
  def deliver_unknown_user_warning(email)
    enqueue(UnknownUser, email)
  end


  def deliver_welcome_email(user)
    enqueue(Welcome, user.id)
  end

  
  def deliver_password_reset(user)
    enqueue(PasswordReset, user.id)
  end


  def deliver_admin_question(from_email, message, name)
    enqueue(AdminQuestion, from_email, message, name)
  end


  def deliver_daily_bulletin(user, date_string)
    enqueue(DailyBulletin, user.id, date_string)
  end
  
  def deliver_feed_owner_welcome(feed)
    enqueue(FeedWelcome, feed.id)
  end

  def deliver_thank_notification(thank)
    # TODO: Implement
  end

  def deliver_share_notification(user, item, recipient_email)
    # TODO: Implement
    enqueue(ShareNotification, user, item, recipient_email)
  end

  private
  
  def enqueue(*args)
    @queuer.enqueue(*args)
  end

  def send_post_to_neighborhood(post, neighborhood)
    # Send to the people in the neighborhood
    # Who receive posts live
    recipient_ids = neighborhood.users.receives_posts_live.map(&:id)

    # Who are not the poster
    recipient_ids.delete(post.user_id)

    # Send it
    recipient_ids.each do |user_id|
      enqueue(PostNotification, post.id, user_id)
    end
  end
  
end
