#通过Mutex类实现线程同步控制，如果在多个线程钟同时需要一个程序变量，可以将这个变量部分使用lock锁定。
#除了使用lock锁定变量，还可以使用try_lock锁定变量，还可以使用Mutex.synchronize同步对某一个变量的访问。


require "thread"  
puts "Synchronize Thread"  
  
@num=200  
@mutex=Mutex.new  
  
=begin
def buy_ticket(num)
  @mutex.synchronize do
    if @num>=num
      @num=@num-num
      puts "you have successfully bought #{num} tickets"  
    else  
      puts "sorry,no enough tickets,#{@num} tickets left."  
    end
  end
end
=end

def buy_ticket(num)  
  @mutex.lock 
  if @num>=num  
    @num=@num-num  
    puts "you have successfully bought #{num} tickets"  
  else  
    puts "sorry,no enough tickets,#{@num} tickets left."  
  end
  @mutex.unlock  
end  
  
ticket1=Thread.new 10 do  
  10.times do |value|  
		ticketNum=15  
		buy_ticket(ticketNum)  
		sleep 1  
  end  
end  
  
ticket2=Thread.new 10 do  
  10.times do |value|  
		ticketNum=20  
		buy_ticket(ticketNum)  
		sleep 1  
  end  
end  
  
sleep 1  
ticket1.join  
ticket2.join 




