class API
  class Registrations < Base

    # Returns Account validation errors
    #
    # A utility for seeing whether an account will be valid. Does *not*
    # attempt to save the account.
    #
    # Returns the validation errors
    get "/:community_id/validate" do |community_id|
      control_access :public

      user = User.find_by_email(params['email'])
      if user && user.valid_password?(params['password'])
        warden.set_user(user, :scope => :user)
        serialize Account.new(user)
      else
        user = User.new(:full_name => params["full_name"],
                        :email => params["email"],
                        :facebook_uid => params["fb_uid"],
                        :community_id => community_id)

        serialize user.validation_errors
      end
    end

    # Creates a new account, assigns profile attributes, sets as current
    # authenticated user
    #
    # Request params:
    #   full_name
    #   email
    #   password
    #   about
    #   interest_list
    #   skill_list
    #   good_list
    #   referral_source
    #   referral_metadata
    #
    # Returns serialized account on success
    # Returns validation errors on failure
    post "/:community_id/new" do |community_id|
      control_access :public
      params.merge!(request_body) rescue
      user = User.new(:full_name => params["full_name"],
                      :email => params["email"],
                      :community_id => community_id,
                      :password => params["password"])

      if user.valid?
        user.about = params["about"]
        user.interest_list = params["interests"]
        user.skill_list = params["skills"]
        user.good_list = params["goods"]
        user.calculated_cp_credits = 0
        user.organizations = params["organizations"]

        user.save
        warden.set_user(user, :scope => :user)
        serialize Account.new(current_user)
      else
        serialize user.validation_errors
      end
    end

    post "/:community_id/civic_hero_nomination" do |community_id|
      control_access :public
      CivicHeroNomination.create!(
        community_id: community_id,
        nominee_name: params["nominee_name"],
        nominee_email: params["nominee_email"],
        nominator_name: params["nominator_name"],
        nominator_email: params["nominator_email"],
        reason: params["nomination_reason"]
      )
      200
    end

    post "/:community_id/civic_leader_application" do |community_id|
      control_access :public
      CivicLeaderApplication.create!(
        community_id: community_id,
        name: params["name"],
        email: params["email"],
        reason: params["application_reason"]
      )
      200
    end

    # Creates a new account with facebook connect, assigns profile
    # attributes, sets as current authenticated user
    #
    # Request params:
    #   full_name
    #   email
    #   password
    #   about
    #   interest_list
    #   skill_list
    #   good_list
    #   referral_source
    #   referral_metadata
    #   fb_auth_token
    #   fb_uid
    #
    # Returns serialized account on success
    # Returns validation errors on failure
    post "/:community_id/facebook" do |community_id|


      user = User.new(:full_name => params["full_name"],
                   :email => params["email"],
                   :address => params["address"],
                   :community_id => community_id,
                   :referral_source => params["referral_source"])

      user.private_metadata["fb_access_token"] = params["fb_auth_token"]
      user.facebook_uid = params["fb_uid"]

      if user.valid?
        user.about = params["about"]
        user.interest_list = params["interests"]
        user.skill_list = params["skills"]
        user.good_list = params["goods"]
        user.referral_metadata = params["referral_metadata"]
        user.calculated_cp_credits = 0

        user.save
        warden.set_user(user, :scope => :user)
        serialize Account.new(user)
      else
        serialize user.validation_errors
      end
    end

    # Returns community exterior
    get "/:community_id" do |community_id|
      control_access :public

      serialize  Community.find_by_id(community_id).exterior
    end

  end

end
