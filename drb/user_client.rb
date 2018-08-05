require 'drb'

user_server=DRbObject.new_with_uri("druby://127.0.0.1:61676")

user=user_server.find(2)

puts user.inspect
puts "UserName: #{user.username}"
user.username="simon"
puts "UserName: #{user.username}"




