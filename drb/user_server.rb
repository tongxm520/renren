require 'drb'
require File.join(File.dirname(__FILE__), "user.rb")

class UserServer
  attr_accessor :users

  def find(id)
    self.users[id-1]
  end
end

user_server=UserServer.new
user_server.users=[]

5.times do |i|
  user=User.new
  user.username=i+1
  user_server.users << user
end

DRb.start_service("druby://127.0.0.1:61676",user_server)
DRb.thread.join





