module Stats
  class Contexts
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def actions
      @actions ||= Stats::TopContextsQuery.new(user, :limit => 5).result
    end

    def running_actions
      @running_actions ||= Stats::TopContextsQuery.new(user, :limit => 5, :running => true).result
    end
  end
end
