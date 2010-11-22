require 'spec_helper'

class Friendship
  include DataMapper::Resource
  property :person_id, Integer, :key => true
  property :friend_id, Integer, :key => true
  property :accepted_at, DateTime
  
  belongs_to :person
  belongs_to :friend, :model => "Person", :child_key => [:friend_id]
  
end

class Person
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :deleted_at, ParanoidDateTime
  
  is :friendly
end

# new classes
class Homie
  include DataMapper::Resource
  property :gangster_id, Integer, :key => true
  property :friend_id, Integer, :key => true

  belongs_to :gangster
  belongs_to :friend, :model => "Gangster", :child_key => [:friend_id]

end

class Gangster
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  is :friendly, :friendship_class => "Homie", :require_acceptance => false
end

describe 'DataMapper::Is::Friendly' do
  with_adapters do
    before(:all) do
      Friendship.auto_migrate!; Person.auto_migrate!
    end
  
    it "should have proper options set" do
      Person.friendly_options.friendship_class.should == Friendship
      Person.friendly_options.friend_class.should     == Person
      Person.friendly_options.friendship_foreign_key.should == :person_id
      Person.friendly_options.require_acceptance?.should == true
    end

    describe "with friendships" do
      before(:all) do
        Friendship.auto_migrate!; Person.auto_migrate!
    
        @quentin = Person.create(:name => "quentin")
        @aaron = Person.create(:name => "aaron") # state: "pending"
        @joe = Person.create(:name => "joe")
      end
    
      it "should work" do
        lambda do
          @joe.request_friendship(@quentin)
        end.should change(Friendship, :count).by(1)
      end
  
      it "should only recognize friends that are confirmed" do
        @joe.friends.should_not include(@quentin)
        @quentin.friends.should_not include(@joe)
      end

      it "should set the proper relationships" do
        # see if associations are correct
        log("@quention.friendship_requests")
        @quentin.friendship_requests.should_not include(@joe)
        log("@joe.friendship_requests")
        @joe.friendship_requests.should include(@quentin)
        log("@quention.friendships_to_accept")
        @quentin.friendships_to_accept.should include(@joe)
        log("@joe.friendships_to_accept")
        @joe.friendships_to_accept.should_not include(@quentin)
      end
  
      it "should also work with convenience methods" do
        @quentin.friendship_to_accept?(@joe).should be_true
        @joe.friendship_requested?(@quentin).should be_true      
      end
  
      it "should have to be confirmed" do
        # confirm the request
        @quentin.confirm_friendship_with(@joe)

        # see if associations are correct
        @quentin.friends.should include(@joe)
        @joe.friends.should include(@quentin)
    
        @quentin.friendship_to_accept?(@joe).should be_false
        @joe.friendship_requested?(@quentin).should be_false
      end
      
      it "should not be added twice" do
        lambda do
          @joe.request_friendship(@quentin)
          #@joe.should have(1).friends
          #@quentin.should have(1).friends
          @joe.friends.size.should == 1
          @quentin.friends.size.should ==1
        end.should_not change(Friendship,:count)
      end

      it "should be able to have multiple friends" do
        @joe.request_friendship(@aaron)
        @joe.friendship_requested?(@aaron).should be_true
        @aaron.friendship_to_accept?(@joe).should be_true
      end
  
      it "should be able to delete friendships" do
        lambda do
          # joe sleeps with quentin's wife perhaps
          @quentin.end_friendship_with(@joe)
        end.should change(Friendship,:count)
    
        @quentin.reload; @joe.reload
    
        @quentin.friends.should_not include(@joe)
        @joe.friends.should_not include(@quentin)
      end
  
    end


    describe "without requiring acceptance" do
      before(:all) do
        Homie.auto_migrate!; Gangster.auto_migrate!
    
        @quentin = Gangster.create(:name => "quentin")
        @aaron = Gangster.create(:name => "aaron") # state: "pending"
        @joe = Gangster.create(:name => "joe")
      end
    
      it "should work" do
        lambda do
          @joe.request_friendship(@quentin)
        end.should change(Homie, :count).by(1)
      end
  
      it "should recognize every friend request" do
        @joe.friends.should include(@quentin)
        @quentin.friends.should include(@joe)
      end

      it "should set the proper relationships" do
        # see if associations are correct
        @quentin.friendship_requests.should_not include(@joe)
        @joe.friendship_requests.should include(@quentin)
        @quentin.friendships_to_accept.should include(@joe)
        @joe.friendships_to_accept.should_not include(@quentin)
      end
  
      it "should not need acceptance" do
        @quentin.friendship_to_accept?(@joe).should be_false
        @joe.friendship_requested?(@quentin).should be_true     
      end
        
      it "should not be added twice" do
        lambda do
          @joe.request_friendship(@quentin)
          # @joe.should have(1).friends
          # @quentin.should have(1).friends
          @joe.friends.size.should == 1
          @quentin.friends.size.should ==1
          
        end.should_not change(Homie,:count)
      end

      it "should be able to have multiple friends" do
        @joe.request_friendship(@aaron)
        @joe.friendship_requested?(@aaron).should be_true
        @aaron.friendship_to_accept?(@joe).should be_false
      end
  
      it "should be able to delete friendships" do
        lambda do
          # joe sleeps with quentin's wife perhaps
          @quentin.end_friendship_with(@joe)
        end.should change(Homie,:count)
    
        @quentin.reload; @joe.reload
    
        @quentin.friends.should_not include(@joe)
        @joe.friends.should_not include(@quentin)
      end
  
    end
  end
end