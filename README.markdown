# dm-is-friendly #

DataMapper plugin that adds self-referential friendship functionality to your models.

**Note: This is NOT officially part of the DataMapper (dm-core, dm-more) project, it just works with DataMapper.

## Why is this plugin useful? ##

If you're building a social app, it will probably save you 12 minutes, tops.

## Installation ##

Probably make sure you can use gemcutter gems first.

    $ [sudo] gem install dm-is-friendly.

Create a file for the friendship (or whatever you want to call it) class. An example is below.

## Example DataMapper resource (i.e. model) ##

    # /app/models/friendship.rb
    class Friendship
      include DataMapper::Resource
      
      # you need all of this
      property :person_id, Integer, :key => true
      property :friend_id, Integer, :key => true
      property :accepted_at, DateTime, :nullable => true

      belongs_to :person, :child_key => [:person_id]
      belongs_to :friend, :class_name => "Person", :child_key => [:friend_id]

    end
    
    # /app/models/person.rb
    class Person
      include DataMapper::Resource
      property :id, Integer, :serial => true
      property :name, String
      
      # you need this part
      is :friendly
    end
    
### There are options ###
  
    # /some/folder/homie.rb
    class Homie
      property :gangster_id, Integer, :key => true
      property :friend_id, Integer, :key => true
      property :accepted_at, DateTime, :nullable => true

      belongs_to :gangster
      belongs_to :homie, :child_key => [:friend_id]
    end

    # /some/folder/gangster.rb
    class Gangster
      is :friendly, :friendship_class => "Homie", :require_acceptance => false
    end
  
This would change the friendship class to Homie, and make it not require friendships to be accepted. I admit, it was kind of dumb to do it that way, but I just made this into a gem so that it wasn't lying around my code base. I'll make it more useful in the next run.

