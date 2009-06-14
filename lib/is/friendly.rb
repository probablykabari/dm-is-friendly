# Home baked self-referential :through relationship
module DataMapper
  module Is
    module Friendly
      
      def is_friendly(options = {})
        options = {:require_acceptance => true, :friendship_class => "Friendship" }.merge(options)
        @friendly_config = FriendlyConfig.new(self, options)
        class << self; self; end.class_eval do
          attr_reader :friendly_config      
          def friendly_config; @friendly_config; end
        end
        
        class_eval(<<-EOS,(__FILE__),(__LINE__)
        has n, :friendships, :class_name => "#{friendly_config.friendship_class.name}"
        has n, :friends_by_me, :through => :friendships, :class_name => "#{self.name}",
                         :child_key => [:#{Extlib::Inflection.foreign_key(self.name)}]
        has n, :friended_by, :through => :friendships, :class_name => "#{self.name}",
                             :remote_name => "#{self.name.downcase}", :child_key => [:friend_id]
        EOS
        )
        
        # stuff like this didn't work as of DM 0.9.10, hence the mass amounts of hand ql queries
        # returns all the people I have requested frienship from
        # has n, :friendship_requests, :through => :friendships, :class_name => "Person",
                                     # :child_key => [:person_id]
        # returns all the people that have requested my friendship
        # has n, :friendships_to_accept, :through => :friendships, :class_name => "Person",
                                     # :remote_name => :person, :child_key => [:friend_id]
        
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
          friends_sql = <<-SQL
             SELECT #{friendly_config.friend_table_name}.* FROM #{friendly_config.friend_table_name} INNER JOIN #{friendly_config.friendship_table_name} 
             ON #{friendly_config.friend_table_name}.id = #{friendly_config.friendship_table_name}.#{friendly_config.friendship_foreign_key} WHERE ((#{friendly_config.friendship_table_name}.friend_id = #{id}) #{acceptance_sql(true)})
             UNION
             SELECT #{friendly_config.friend_table_name}.* FROM #{friendly_config.friend_table_name} INNER JOIN #{friendly_config.friendship_table_name} 
             ON #{friendly_config.friend_table_name}.id = #{friendly_config.friendship_table_name}.friend_id WHERE ((#{friendly_config.friendship_table_name}.#{friendly_config.friendship_foreign_key} = #{id}) #{acceptance_sql(true)})
          SQL
          
          self.class.find_by_sql(friends_sql)
        end
        
        # returns all the people I have requested frienship from
        def friendship_requests(friend = nil)
          sql = [%{SELECT #{friendly_config.friend_table_name}.* FROM #{friendly_config.friend_table_name} INNER JOIN #{friendly_config.friendship_table_name}}]
          sql << %{ON #{friendly_config.friend_table_name}.id = #{friendly_config.friendship_table_name}.friend_id}
          sql << %{WHERE ((#{friendly_config.friendship_table_name}.#{friendly_config.friendship_foreign_key} = #{id}) #{acceptance_sql}}
          sql << select_friendship_sql(friend) if friend
          sql << ") #{'LIMIT 1' if friend}"
          self.class.find_by_sql(sql.join(' '))
        end
        
        # returns all the people that have requested my friendship
        def friendships_to_accept(friend = nil)
          sql = [%{SELECT #{friendly_config.friend_table_name}.* FROM #{friendly_config.friend_table_name} INNER JOIN #{friendly_config.friendship_table_name}}]
          sql << %{ON #{friendly_config.friend_table_name}.id = #{friendly_config.friendship_table_name}.#{friendly_config.friendship_foreign_key}} 
          sql << %{WHERE ((#{friendly_config.friendship_table_name}.friend_id = #{id}) #{acceptance_sql}}
          sql << select_friendship_sql(friend,true) if friend
          sql << ") #{'LIMIT 1' if friend}"
          self.class.find_by_sql(sql.join(' '))
        end
        
        # see if there is a pending friendship request from this person to another
        def friendship_requested?(friend)
          # return false unless friendly_config.require_acceptance?
          !friendship_requests(friend).empty? #.detect{|f| f.friend_id = friend.id} #.first('friendships.friend_id' => friend.id)
        end
        
        # see if user has a friend request to accept from this person
        def friendship_to_accept?(friend)
          return false unless friendly_config.require_acceptance?
          !friendships_to_accept(friend).empty? #first('friendships.person_id' => friend.id)
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
          self.friendship(friend,{:accepted_at => nil}).update_attributes({:accepted_at => Time.now})
          # reload so old relationship won't be lingering
          friend.reload
          self.reload
        end

        # Accepts a user object and deletes a friendship between both 
        # users.
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