#使用 ConditonVariable进行同步控制，能够在一些致命的资源竞争部分挂起线程直到有可用的资源为止。

require "thread"  
puts "thread synchronize by ConditionVariable"  
  
mutex = Mutex.new  
resource = ConditionVariable.new  
  
a = Thread.new {  
  mutex.synchronize {  
    #这个线程目前需要resource这个资源  
    resource.wait(mutex)   
    puts "get resource"  
  }  
}  
  
b = Thread.new {  
  mutex.synchronize {  
    #线程b完成对resourece资源的使用并释放resource  
    resource.signal  
  }  
}  
  
a.join  
puts "complete"

#mutex 是声明的一个资源，然后通过ConditionVariable来控制申请和释放这个资源。
#b线程完成了某些工作之后释放资源resource.signal,这样a线程就可以获得一个mutex资源然后进行执行。

