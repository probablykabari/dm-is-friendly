# Home baked self-referential :through relationship
module DataMapper
  module Is
    module Friendly
      
      def is_friendly(options = {})
        options = {:require_acceptance => true, :friendship_class => "Friendship" }.merge(options)
        @friendly_config = FriendlyConfig.new(self, options)        
        def self.friendly_config; @friendly_config; end
        
        class_eval(<<-RUBY,(__FILE__),(__LINE__+1)
        has n, :friendships, :model => "#{friendly_config.friendship_class.name}"
        has n, :friends_by_me, :through => :friendships, :model => "#{self.name}", :via => :#{self.name.downcase}
        has n, :friended_by, :through => :friendships, :model => "#{self.name}",
                             :via => :#{self.name.downcase}
        RUBY
        )
        
        include DataMapper::Is::Friendly::InstanceMethods
      end
      
      class FriendlyConfig
        attr_reader :friendship_class, :friend_class
        
        def initialize(klazz, opts)
          @friendship_class = Object.full_const_get(opts[:friendship_class])
          @friend_class = klazz
          @require_acceptance = opts[:require_acceptance]
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
        
        def friends
          friendship_requests(nil,true).union(friendships_to_accept(nil,true))
        end
                
        # returns all the people I have requested frienship from
        def friendship_requests(friend = nil, include_accepted = false)
          conditions = {}
          if friendly_config.require_acceptance?
            include_accepted ? (conditions[:accepted_at.not] = nil) :(conditions[:accepted_at] = nil)
          end
          
          if friend
            conditions[:friend_id] = friend.id
            conditions[:limit] = 1
          end
          conditions[friendly_config.friendship_foreign_key] = self.id
          ids = friendly_config.friendship_class.all(conditions).collect(&:friend_id)
          self.class.all( :id => ids)
        end
                
        # returns all the people that have requested my friendship
        def friendships_to_accept(friend = nil, include_accepted = false)
          conditions = {}
          if friendly_config.require_acceptance?
            include_accepted ? (conditions[:accepted_at.not] = nil) : (conditions[:accepted_at] = nil)
          end
          
          if friend
            conditions[friendly_config.friendship_foreign_key] = friend.id
            conditions[:limit] = 1
          end
          
          conditions[:friend_id] = self.id
          ids = friendly_config.friendship_class.all(conditions).collect(&friendly_config.friendship_foreign_key.to_sym)
          self.class.all(:id => ids)
        end
        
        # see if there is a pending friendship request from this person to another
        def friendship_requested?(friend)
          # return false unless friendly_config.require_acceptance?
          !friendship_requests(friend).empty?
        end
        
        # see if user has a friend request to accept from this person
        def friendship_to_accept?(friend)
          return false unless friendly_config.require_acceptance?
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
        
        # Accepts a user object and updates an existing friendship to
        # be accepted.
        def confirm_friendship_with(friend)
          self.friendship(friend,{:accepted_at => nil}).update({:accepted_at => Time.now})
          # reload so old relationship won't be lingering in the IdentityMap
          friend.reload
          self.reload
        end

        # Accepts a user object and deletes a friendship between both users.
        def end_friendship_with(friend)
          self.friendship(friend).destroy if self.is_friends_with?(friend)
        end
        
        protected
        # Accepts a user object and returns the friendship object 
        # associated with both users.
        def friendship(friend, opts = {})
          friendly_config.friendship_class.first({:conditions => ["(#{friendly_config.friendship_foreign_key} = ? AND friend_id = ?) OR (friend_id = ? AND #{friendly_config.friendship_foreign_key} = ?)", self.id, friend.id, self.id, friend.id]}.merge(opts) )
        end
        
        def friendly_config; self.class.friendly_config; end                
        
        private
        def acceptance_sql(accepted = false)
          "AND #{friendly_config.friendship_table_name}.accepted_at IS #{accepted ? 'NOT' : ''} NULL" if friendly_config.require_acceptance?
        end
        
        # because of DM bug in 0.9.10
        def select_friendship_sql(friend, for_me = false)
          "AND #{friendly_config.friendship_table_name}.#{for_me ? friendly_config.friendship_foreign_key : 'friend_id'} = #{friend.id}"
        end
        
      end
    end # Friendly
  end # Is
end # DataMapper