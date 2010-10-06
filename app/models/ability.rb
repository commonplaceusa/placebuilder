class Ability
  include CanCan::Ability
  
  def initialize(user)
    if user.new_record?
      can :create, User
      can :create, UserSession
    else
      can :update, User
      can :create, Post
      can :destroy, Post, :user_id => user.id
      can :destroy, UserSession
    end
    
    can :read, Community
    can :read, Post
    can :read, User
    can :read, Announcement
    can :read, Event
    can :manage, Organization
    can :read, ActsAsTaggableOn::Tag
  end

end
