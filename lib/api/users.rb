class API
  class Users < Base

    post "/:id/messages" do |id|
      user = User.find(id)
      halt [401, "wrong community"] unless in_comm(user.community.id)
      message = Message.new(:subject => request_body['subject'],
                            :body => request_body['body'],
                            :messagable => user,
                            :user => current_account)
      if message.save
        kickoff.deliver_user_message(message)
        [200, ""]
      else
        [400, "errors"]
      end
    end

    get "/:id" do |id|
      user = User.find(id)
      halt [401, "wrong community"] unless in_comm(user.community.id)
      serialize user
    end

  end
end