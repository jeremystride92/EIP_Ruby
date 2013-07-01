class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new

    can :manage, user.class, id: user.id # Handle both User and Cardholder

    if user.is_a? Cardholder
      can :checkin, Card, cardholder_id: user.id
      return # Cardholder doesn't respond to #venue_manager?, etc.
    end

    if user.venue_manager? || user.venue_owner?
      can :read, Venue, id: user.venue_id
      can :manage, CardLevel, venue_id: user.venue_id
      can :manage, Promotion, venue_id: user.venue_id

      can :read, User, venue_id: user.venue_id

      can :manage, Card do |card|
        card.venue.id == user.venue_id
      end

      can :manage, Benefit do |benefit|
        benefit.beneficiary.venue.id == user.venue_id
      end

      can :create, GuestPass do |guest_pass|
        guest_pass.card.venue.id == user.venue_id
      end
    end

    if user.venue_owner?
      can :manage, Venue, id: user.venue_id
      can :create, User, venue_id: user.venue_id
      can [:update, :delete], User do |managed_user|
        managed_user.venue_id == user.venue_id &&
          !managed_user.venue_owner?
      end
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
