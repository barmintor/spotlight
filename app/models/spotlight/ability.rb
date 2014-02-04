module Spotlight::Ability
  include CanCan::Ability

  def initialize(user)
    user ||= ::User.new
    
    # This is the "right" way to do it. But it doesn't work in rails 4
    # until this PR is merged: https://github.com/ryanb/cancan/pull/917
    # can :create, Spotlight::Exhibit, admin_roles: { id: user.role_ids } 
    # Until then, workaround:
    can [:update, :edit_metadata_fields, :edit_facet_fields], Spotlight::Exhibit do |exhibit|
      exhibit.roles.where(id: user.role_ids, role: 'admin').any?
    end

    can [:curate, :update_all_pages], Spotlight::Exhibit do |exhibit|
      # any curator or admin role
      exhibit.roles.where(id: user.role_ids).any?
    end

    can [:read, :index], [Spotlight::Exhibit, Spotlight::Page, Spotlight::Search]

      # any curator or admin role
    if Spotlight::Exhibit.default.roles.where(id: user.role_ids).any?
      can [:create, :update, :destroy], [Spotlight::Search, Spotlight::Page]
      can :update_all, Spotlight::Search
    end
  end
end
