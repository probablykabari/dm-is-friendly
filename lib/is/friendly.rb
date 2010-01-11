# Home baked self-referential :through relationship
module DataMapper
  module Is
    module Friendly
      
      def is_friendly(options = {})
        options = {:require_acceptance => true, :friendship_class => "Friendship" }.merge(options)
        @friendly_options = FriendlyConfig.new(self, options)        
        def self.friendly_options; @friendly_options; end
        
        class_eval(<<-RUBY,(__FILE__),(__LINE__+1)
        has n, :friendships, :model => #{options[:friendship_class]}
        has n, :friends_by_me, :through => :friendships, :model => "#{self.name}", :via => :#{self.name.downcase}
        has n, :friended_by, :through => :friendships, :model => "#{self.name}",
                             :via => :#{self.name.downcase}
        RUBY
        )
        
        include DataMapper::Is::Friendly::InstanceMethods
      end
      
      # This class holds the configuration options for the plugin.
      class FriendlyConfig
        attr_reader :friend_class
        
        def initialize(klazz, opts)
          @friendship_class_name = opts[:friendship_class]
          @friend_class = klazz
          @require_acceptance = opts[:require_acceptance]
        end
        
        def friendship_class
          Object.full_const_get(@friendship_class_name)
        end
        
        def friendship_foreign_key
          Extlib::Inflection.foreign_key(friend_class.name)
        end
      
        def friend_foreign_key
          Extlib::Inflection.foreign_key(friendship_class.name)
        end
        
        def friend_table_name
          Extlib::Inflection.tableize(friend_class.name)
        end
      
        def friendship_table_name
          Extlib::Inflection.tableize(friendship_class.name)
        end
              
        def require_acceptance?
          @require_acceptance
        end   
      end
      
      module InstanceMethods
        
        # returns all of the friends this person has that are accepted
        def friends
          friendship_requests(nil,true).union(friendships_to_accept(nil,true))
        end
                
        # returns all the people I have requested frienship from
        def friendship_requests(friend = nil, include_accepted = false)
          conditions = {}
          friend_acceptance_condition(conditions, include_accepted)
          friend_scope_condition(conditions, friend)
          
          conditions[friendly_options.friendship_foreign_key] = self.id
          ids = friendly_options.friendship_class.all(conditions).collect(&:friend_id)
          self.class.all( :id => ids)
        end
                
        # returns all the people that have requested my friendship
        def friendships_to_accept(friend = nil, include_accepted = false)
          conditions = {}
          friend_acceptance_condition(conditions, include_accepted)
          friend_scope_condition(conditions, friend, true)
          
          conditions[:friend_id] = self.id
          ids = friendly_options.friendship_class.all(conditions).collect(&friendly_options.friendship_foreign_key.to_sym)
          self.class.all(:id => ids)
        end
        
        # see if there is a pending friendship request from this person to another
        def friendship_requested?(friend)
          # return false unless friendly_options.require_acceptance?
          !friendship_requests(friend).empty?
        end
        
        # see if user has a friend request to accept from this person
        def friendship_to_accept?(friend)
          return false unless friendly_options.require_acceptance?
          !friendships_to_accept(friend).empty?
        end

        # Accepts a user object and returns true if both users are
        # friends and the friendship has been accepted.
        def is_friends_with?(friend)
          !self.friendship(friend).nil?
        end        
        
        # request friendship from "friend"
        def request_friendship(friend)
          return false if friendship(friend)
          self.friendships.create(:friend => friend)
        end
        
        # Accepts a user  and updates an existing friendship to be accepted.
        def confirm_friendship_with(friend)
          self.friendship(friend,{:accepted_at => nil}).update({:accepted_at => Time.now})
          # reload so old relationship won't be lingering in the IdentityMap
          friend.reload
          self.reload
        end

        # Accepts a user and deletes a friendship between both users.
        def end_friendship_with(friend)
          self.friendship(friend).destroy if self.is_friends_with?(friend)
        end
        
        protected
        # Accepts a user and returns the friendship associated with both users.
        def friendship(friend, opts = {})
          friendly_options.friendship_class.first({:conditions => ["(#{friendly_options.friendship_foreign_key} = ? AND friend_id = ?) OR (friend_id = ? AND #{friendly_options.friendship_foreign_key} = ?)", self.id, friend.id, self.id, friend.id]}.merge(opts) )
        end
        
        def friendly_options; self.class.friendly_options; end                
        
        private
        def friend_acceptance_condition(conditions, accepted = false)
          accepted ? (conditions[:accepted_at.not] = nil) : (conditions[:accepted_at] = nil) if friendly_options.require_acceptance?
        end
        
        def friend_scope_condition(conditions, friend = nil, for_me = false)
          return unless friend
          key_name = for_me ? friendly_options.friendship_foreign_key : :friend_id
          conditions[key_name] = friend.id
          conditions[:limit] = 1
        end
      end
    end # Friendly
  end # Is
end # DataMapper