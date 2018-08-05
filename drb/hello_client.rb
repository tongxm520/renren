require 'drb'
server=DRbObject.new_with_uri("druby://127.0.0.1:61676")

puts server.say_hello
puts server.inspect



