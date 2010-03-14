dm-is-friendly
==============

DataMapper plugin that adds self-referential friendship functionality to your models.

## Why is this plugin useful? ##

If you're building an app that require this type of relation then it will probably save some time to use this instead of rolling our own :)

## Installation ##

    $ [sudo] gem install dm-is-friendly.

Create a file for the friendship (or whatever you want to call it) class.

## Example DataMapper model ##

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
  
      is :friendly #, :friendship_class => "Friendship", :require_acceptance => true
    end

## Use It ##

    @quentin = Person.create(:name => "quentin")
    @joe     = Person.create(:name => "joe")
    
    # request friendship
    @joe.request_friendship(@quentin)
    
    # Find friend requests sent
    @joe.friendship_requests              # => [#<Person @id=1 @name="quentin">]
    @joe.friendship_requested?(@quentin)  # => true
    
    # Find recieve friend requests
    @quentin.friendships_to_accept       # => [#<Person @id=2 @name="joe">]
    @quentin.friendship_to_accept?(@joe) # => true
    
    # Check friendships
    @quentin.is_friends_with?(@joe) # => false
    
    # Accept friendships
    @quentin.confirm_friendship_with(@joe)
    @quentin.is_friends_with?(@joe) # => true
    
    # End friendships :(
    @quentin.end_friendship_with(@joe) # => true
    
### Options ###

**:require_acceptance**
Set this if friendships should be accepted before showing up in the query of friends.
Default: true
**Must provide the :accepted_at Property*

**:friendship_class**
Set this to something other than "Friendship" if you want.
Default: "Friendship"



