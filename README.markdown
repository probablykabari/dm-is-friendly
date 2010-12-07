dm-is-friendly
==============

DataMapper plugin that adds self-referential friendship functionality to your models.

## Why is this plugin useful? ##

If you're building an app that require this type of relation then it will probably save some time to use this instead of rolling our own :)

## Installation ##

    $ [sudo] gem install dm-is-friendly.

## Example DataMapper model ##

    class Person
      include DataMapper::Resource
      property :id, Serial
      property :name, String
  
      is :friendly
    end

A model called "Friendship" will be created for you and will include the association. Several helper methods (shown below) are added as well. Documentation of these methods is [here](http://rubydoc.info/github/RipTheJacker/dm-is-friendly/master/DataMapper/Is/Friendly/InstanceMethods).

### Options ###

**:require_acceptance**
Set this if friendships should be accepted before showing up in the query of friends:   Default: true

**:friendship_class**
Set this to something other than "Friendship" if you want:  Default: "Friendship"

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
    
Or without requiring acceptance
  
    class Person
      include DataMapper::Resource
      property :id, Serial
      property :name, String

      is :friendly, :require_acceptance => false
    end
 
    @sue = Person.create(:name => "Sue")
    @julie = Person.create(:name => "Julie")
    
    @sue.request_friendship(@julie)
    @julie.is_friends_with?(@sue) # => 'true' since friendships don't need to be accepted
    
## Contributing ##

If you want to contribute to this project, just fork it and make changes/pull requests in the **next** branch. Please run tests against ruby 1.8.7 and 1.9.2 before submitting! Everything else you need is in the Gemfile :)

There are also a few roadmap items in the #issues section on github.

Thanks!

