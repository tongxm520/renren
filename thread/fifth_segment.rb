require 'thread'
require 'monitor'
require 'net/http'

# Our sample set of currencies
currencies = ['ARS','AUD','CAD','CNY','DEM','EUR','GBP','HKD','ILS','INR','USD','XAG','XAU']

# Store our results here
results = Array.new

# Create a mutex for the shared results array
results_mutex = Mutex.new

# Set a finite number of simultaneous worker threads that can run
thread_count = 5

# Create an array to keep track of threads
threads = Array.new(thread_count)

# Create a work queue for the producer to give work to the consumer
work_queue = SizedQueue.new(thread_count)

# Add a monitor so we can notify when a thread finishes and we can schedule a new one
threads.extend(MonitorMixin)

# Add a condition variable on the monitored array to tell the consumer to check the thread array
threads_available = threads.new_cond

# Add a variable to tell the consumer that we are done producing work
sysexit = false

consumer_thread = Thread.new do
  loop do
    # Stop looping when the producer is finished producing work
    break if sysexit & work_queue.length == 0
    found_index = nil

    # The MonitorMixin requires us to obtain a lock on the threads array in case
    # a different thread may try to make changes to it.
    threads.synchronize do
      # First, wait on an available spot in the threads array.  This fires every
      # time a signal is sent to the "threads_available" variable
      threads_available.wait_while do
        threads.select { |thread| thread.nil? || thread.status == false  ||thread["finished"].nil? == false}.length == 0
      end
      # Once an available spot is found, get the index of that spot so we may
      # use it for the new thread
      found_index = threads.rindex { |thread| thread.nil? || thread.status == false || thread["finished"].nil? == false }
    end

    # Get a new unit of work from the work queue
    currency = work_queue.pop

    # Pass the currency variable to the new thread so it can use it as a parameter to go
    # get the exchange rates
    threads[found_index] = Thread.new(currency) do
      results_mutex.synchronize do
        results << Net::HTTP.get("download.finance.yahoo.com","/d/quotes.csv?e=.csv&amp;f=sl1d1t1&amp;s=USD#{currency}=X")
      end

      # When this thread is finished, mark it as such so the consumer knows it is a
      # free spot in the array.
      Thread.current["finished"] = true

      # Tell the consumer to check the thread array
      threads.synchronize do
        threads_available.signal
      end
    end
  end
end

producer_thread = Thread.new do
  # For each currency we need to download...
  currencies.each do |currency|
    # Put the currency on the work queue
    work_queue << currency

    # Tell the consumer to check the thread array so it can attempt to schedule the
    # next job if a free spot exists.
    threads.synchronize do
      threads_available.signal
    end
  end
  # Tell the consumer that we are finished downloading currencies
  sysexit = true
end

# Join on both the producer and consumer threads so the main thread doesn't exit while
# they are doing work.
producer_thread.join
consumer_thread.join

# Join on the child processes to allow them to finish (if any are left)
threads.each do |thread|
  thread.join unless thread.nil?
end

# Show our downloaded currencies as they are stored in the array
puts results.inspect
puts "#{results.length} currencies returned."
puts "DONE!"

=begin
Using the mutex, shown above, we now consistently get all 13 currencies back as expected:
["\"USDARS=X\",4.859,\"12/7/2012\",\"4:15pm\"\r\n", "\"USDCNY=X\",6.2254,\"12/7/2012\",\"4:15pm\"\r\n", "\"USDCAD=X\",0.9905,\"12/7/2012\",\"4:15pm\"\r\n", "\"USDAUD=X\",0.9536,\"12/7/2012\",\"4:15pm\"\r\n", "\"USDDEM=X\",0.00,\"N/A\",\"N/A\"\r\n", "\"USDEUR=X\",0.7735,\"12/7/2012\",\"4:15pm\"\r\n", "\"USDGBP=X\",0.6235,\"12/7/2012\",\"4:15pm\"\r\n", "\"USDHKD=X\",7.7501,\"12/7/2012\",\"4:15pm\"\r\n", "\"USDILS=X\",3.8319,\"12/7/2012\",\"4:15pm\"\r\n", "\"USDINR=X\",54.475,\"12/7/2012\",\"4:15pm\"\r\n", "\"USDUSD=X\",0.00,\"N/A\",\"7:47am\"\r\n", "\"USDXAG=X\",0.0303,\"12/7/2012\",\"3:33pm\"\r\n", "\"USDXAU=X\",0.0006,\"12/7/2012\",\"4:15pm\"\r\n"]
13 currencies returned.
DONE!
=end


