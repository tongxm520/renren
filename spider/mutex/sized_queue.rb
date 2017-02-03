#监管数据交接的Queue类实现线程同步
#Queue类就是表示一个支持线程的队列，能够同步对队列末尾进行访问。不同的线程可以使用同一个队列，但是不用担心这个队列中的数据是否能够同步，另外使用SizedQueue类能够限制队列的长度
#SizedQueue类能够非常便捷的帮助我们开发线程同步的应用程序，因为只要加入到这个队列中，就不用关心线程的同步问题。

require "thread"  
puts "SizedQueue Test"  
  
queue = SizedQueue.new(10)  
  
producer = Thread.new do  
  10.times do |i|  
    sleep rand(i) 
    queue << i  
    puts "#{i} produced"  
  end  
end  
  
consumer = Thread.new do  
  10.times do |i|  
    value = queue.pop  
    sleep rand(i/2)  
    puts "consumed #{value}"  
  end  
end  
  
consumer.join  



