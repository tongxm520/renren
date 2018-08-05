require 'net/http'


# Our sample set of currencies
currencies = ['ARS','AUD','CAD','CNY','DEM','EUR','GBP','HKD','ILS','INR','USD','XAG','XAU']

# Create an array to keep track of threads
threads=[]

currencies.each do |currency|
  # Keep track of the child processes as you spawn them
  threads << Thread.new do
    puts Net::HTTP.get("download.finance.yahoo.com","/d/quotes.csv?e=.csv&amp;f=sl1d1t1&amp;s=USD#{currency}=X")
  end
end

# Join on the child processes to allow them to finish

threads.each do |thread|
  thread.join
end

=begin
Notice that we are using an array to keep track of the threads we spawn. We usually want to wait for all threads to finish (or “join”) before moving on, rather than just let them run amok. Also, if you fail to make the parent thread join (wait) on its children, the children could be killed before they finish running. Without the join loop your output would look like this:

DONE!

OK, great - we now know how to use threads. We still have a problem: In our example, let’s say we expand our application to use over 500 currencies (if 500 currencies do indeed exist…). Does this mean I can take my entire application, put these calls into 500 simultaneous threads, and let it run? While we can absolutely do so, it is not such a good idea unless you have a 100 core CPU. Here’s why:

In any multithreaded environment, context switching occurs. Context switching is the process by which a thread is stopped and its state and context are stored allowing other threads to use CPU cycles. Once the competing thread has been interrupted in a similar manner, the context and state of the original thread are loaded and the original thread has the opportunity to run if it gets priority.

One other thing to note - the actual act of context switching in and of itself takes CPU cycles. If you simply spawn as many threads as you can, your system can actually spend more time context switching than actually processing your data. This will slow down your application.

=end

