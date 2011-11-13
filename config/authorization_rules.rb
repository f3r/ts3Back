authorization do

  role :superadmin do
    includes [:admin]
  end

  role :admin do
    includes [:default]
    has_permission_on [:users, :places], :to => [:manage]
    has_permission_on :places, :to => [:user_places, :publish]
  end

  role :agent do
    includes [:default]
    has_permission_on :places, :to => [:create]
    has_permission_on :places, :to => [:manage, :publish] do
      if_attribute :user => is { user }
    end
  end

  role :user do
    includes [:default]
  end

  role :default do
    includes [:guest]
    has_permission_on [:users], :to => [:read, :update] do
      if_attribute :id => is { user.id }
    end
  end
  
  role :guest do
    has_permission_on :places, :to => [:search]
    has_permission_on :places, :to => [:read] do
      if_attribute :published => is { true }
    end
  end

end

privileges do
  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :read, :includes => [:index, :show]
  privilege :create
  privilege :update
  privilege :delete, :includes => :destroy
end