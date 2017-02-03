require 'thread'
mutex=Mutex.new
cv=ConditionVariable.new

a=Thread.new{
  mutex.synchronize{
    puts "A: I have critical section,but will wait for cv"
    cv.wait(mutex)
    puts "A: I have critical section again!I rule!"
  }
}

puts "(Later,back at the ranch...)"

b=Thread.new{
  mutex.synchronize{
    puts "B: Now I am critical,but am done with cv"
    cv.signal
    puts "B: I am still critical,finishing up"
  }
}

a.join
b.join

#在进入临界区并在cv上等待时，会释放该互斥锁mutex，从而才能让别的线程进入临界区，不至于发生死锁。


