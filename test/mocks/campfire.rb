require 'rubygems'
require 'tinder'

module Tinder
  class Campfire
    def initialize(account)
    end
    
    def login(username, password)
      true
    end
    
    def find_room_by_name(room)
      Room.new(room)
    end
    
    def o_hi
      "o aie"
    end
  end
  
  class Room
    attr_accessor :name, :messages
    
    def initialize(name)
      self.name = name
      self.messages = Array.new
    end
    
    def speak(message)
      self.messages << message
    end
    
    def paste(message)
      self.messages << message
    end
  end
end