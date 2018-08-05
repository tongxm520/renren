require 'drb'

class HelloWorldServer
  def say_hello
    "Hello world!"
  end
end

DRb.start_service("druby://127.0.0.1:61676",HelloWorldServer.new)
DRb.thread.join



