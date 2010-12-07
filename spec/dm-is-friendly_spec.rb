require 'spec_helper'

describe DataMapper::Is::Friendly do
  before(:all) do
    class Person
      include DataMapper::Resource
      property :id, Serial
      property :name, String

      is :friendly
    end

    class Member
      include DataMapper::Resource
      property :id, Serial
      property :name, String
      
      is :friendly, :friendship_class => "Membership", :require_acceptance => false
    end
    
    module SomeModule
      class Member
        # include DataMapper::Resource
        # property :id, Serial
        # property :name, String
        # 
        # is :friendly, :friendship_class => "Membership"
      end
    end
  end
  
  describe "configuration" do
    
    context "default" do
      it "should have proper options set" do
        Person.friendly_config.friendship_class.to_s.should == "Friendship"
        Person.friendly_config.reference_model.to_s.should     == "Person"
        Person.friendly_config.friendship_foreign_key.should == :person_id
        Person.friendly_config.require_acceptance?.should == true
      end
    end
    
    context "friendship_class and acceptance set" do
      it "should have proper options set" do
        Member.friendly_config.friendship_class.to_s.should == "Membership"
        Member.friendly_config.reference_model.to_s.should     == "Member"
        Member.friendly_config.friendship_foreign_key.should == :member_id
        Member.friendly_config.require_acceptance?.should == false
      end
    end
    
    context "with a namespace" do
      pending "should have proper options set" do
        SomeModule::Member.friendly_config.friendship_class.to_s.should == "Friendship"
        SomeModule::Member.friendly_config.reference_model.to_s.should     == "Person"
        SomeModule::Member.friendly_config.friendship_foreign_key.should == :person_id
        SomeModule::Member.friendly_config.require_acceptance?.should == true
      end
    end
  end
  
  with_adapters do
  
    describe "default" do
      before(:all) do
        DataMapper.auto_migrate!         
        @quentin = Person.create(:name => "quentin")
        @aaron   = Person.create(:name => "aaron")
        @joe     = Person.create(:name => "joe")
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
        @quentin.friendship_requests.should_not include(@joe)
        @joe.friendship_requests.should include(@quentin)
        @quentin.friendships_to_accept.should include(@joe)
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
          @joe.should have(1).friends
          @quentin.should have(1).friends
        end.should_not change(Friendship,:count)
      end

      it "should be able to have multiple friends" do
        @joe.request_friendship(@aaron)
        @joe.friendship_requested?(@aaron).should be_true
        @aaron.friendship_to_accept?(@joe).should be_true
      end
  
      it "should be able to delete friendships" do
        lambda do
          @quentin.end_friendship_with(@joe)
        end.should change(Friendship,:count)
    
        @quentin.reload; @joe.reload
    
        @quentin.friends.should_not include(@joe)
        @joe.friends.should_not include(@quentin)
      end
  
    end


    describe "without requiring acceptance" do
      before(:all) do
        DataMapper.auto_migrate!
    
        @quentin = Member.create(:name => "quentin")
        @aaron   = Member.create(:name => "aaron")
        @joe     = Member.create(:name => "joe")
      end
    
      it "should work" do
        lambda do
          @joe.request_friendship(@quentin)
        end.should change(Membership, :count).by(1)
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
          @joe.should have(1).friends
          @quentin.should have(1).friends
          
        end.should_not change(Membership,:count)
      end

      it "should be able to have multiple friends" do
        @joe.request_friendship(@aaron)
        @joe.friendship_requested?(@aaron).should be_true
        @aaron.friendship_to_accept?(@joe).should be_false
      end
  
      it "should be able to delete friendships" do
        lambda do
          @quentin.end_friendship_with(@joe)
        end.should change(Membership,:count)
    
        @quentin.reload; @joe.reload
    
        @quentin.friends.should_not include(@joe)
        @joe.friends.should_not include(@quentin)
      end
  
    end
  end
end
