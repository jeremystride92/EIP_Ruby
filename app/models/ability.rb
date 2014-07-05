class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new

    can :manage, user.class, id: user.id # Handle both User and Cardholder

    if user.is_a? Cardholder
      can :redeem, Card, cardholder_id: user.id
      can :reset_pin, Cardholder, id: user.id
      return # Cardholder doesn't respond to #venue_manager?, etc.
    end

    if user.venue_manager? || user.venue_owner?
      can :read, Venue, id: user.venue_id
      can :manage, CardLevel, venue_id: user.venue_id
      can :manage, Promotion, venue_id: user.venue_id
      can :promote, Promotion, venue_id: user.venue_id

      can :read, User, venue_id: user.venue_id

      can :manage, Card, venue: { id: user.venue_id }

      can :manage, Benefit, beneficiary: { venue: {id: user.venue_id } }

      can :create, RedeemableBenefit, card: { venue: { id: user.venue_id } }

      can :manage, Partner, venue_id: user.venue_id

      can :manage, TemporaryCard, partner: { venue_id: user.venue_id }

      can :manage, CardTheme, venue_id: user.venue_id

      can :manage, OnboardingMessage, venue_id: user.venue_id

      can :manage, OnboardingTextMessage, venue_id: user.venue_id

      can :manage, TextusCredential, venue_id: user.venue_id

      can :reset_pin, Cardholder do |cardholder|
        cardholder.venue_ids.include? user.venue_id
      end

      can :resend_onboarding_sms, Cardholder do |cardholder|
        cardholder.venue_ids.include? user.venue_id
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

    if user.has_role?(:venue_partner)
      can :read, Partner, id: user.partner_id 
      can :manage, TemporaryCard, partner_id: user.partner_id 
    end

    if user.has_role?(:site_admin)
      can :manage, :all
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
