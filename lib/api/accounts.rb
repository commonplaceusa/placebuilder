class API
  class Accounts < Base

    helpers do

      def checked_inbox
        current_account.checked_inbox!
        serialize(Account.new(current_account))
      end

    end

    get "/" do 
      serialize Account.new(current_account)
    end

    post "/subscriptions/feeds" do
      feed = Feed.find(params[:id] || request_body['id'])
      halt [401, "wrong community"] unless in_comm(feed.community.id)
      current_account.feeds << feed
      serialize(Account.new(current_account))
    end

    delete "/subscriptions/feeds/:id" do |id|
      current_account.feeds.delete(Feed.find(id))
      serialize(Account.new(current_account))
    end
    
    post "/subscriptions/groups" do
      group = Group.find(params[:id] || request_body['id'])
      halt [401, "wrong community"] unless in_comm(group.community.id)
      current_account.groups << group
      serialize(Account.new(current_account))
    end

    delete "/subscriptions/groups/:id" do |id|
      current_account.groups.delete(Group.find(id))
      serialize(Account.new(current_account))
    end

    post "/mets" do
      user = User.find(params[:id] || request_body["id"])
      halt [401, "wrong community"] unless in_comm(user.community.id)
      current_account.people << user
      serialize(Account.new(current_account))
    end

    delete "/mets/:id" do |id|
      current_account.people.delete(User.find(id))
      serialize(Account.new(current_account))
    end
    
    get "/inbox" do
      checked_inbox()
      serialize(paginate(current_account.inbox.reorder("updated_at DESC")))
    end

    get "/inbox/sent" do
      serialize(paginate(current_account.sent_messages.reorder("updated_at DESC")))
    end

    get "/inbox/feeds" do
      checked_inbox()
      serialize(paginate(current_account.feed_messages.reorder("updated_at DESC")))
    end

  end
end