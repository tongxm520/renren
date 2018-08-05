require 'drb'
require 'thread'

server=DRbObject.new_with_uri("druby://127.0.0.1:22422")

thread=Thread.new do
  20.times do
    puts server.ask_keywords.inspect
  end
end

thread.join








