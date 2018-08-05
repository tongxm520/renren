require 'monitor'

queue = []
queue.extend(MonitorMixin)
cond = queue.new_cond
consumers, producers = [], []
  
for i in 0..5
  consumers << Thread.start(i) do |i|
    print "consumer start #{i}\n"
    while (producers.any?(&:alive?) || !queue.empty?)
      queue.synchronize do
	      cond.wait_while { queue.empty? }
	      print "consumer #{i}: #{queue.shift}\n"
      end
      sleep(0.2) #simulate expense
    end
  end
end

for i in 0..3
  producers << Thread.start(i) do |i|
    id = (65+i).chr
    for j in 0..10 do
      queue.synchronize do
			item = "#{j} #{id}"
			queue << item
			print "producer #{id}: produced #{item}\n"
			j += 1
			cond.broadcast
      end
      sleep(0.1) #simulate expense
    end
  end
end

sleep 0.1 while producers.any?(&:alive?)
sleep 0.1 while consumers.any?(&:alive?)

print "queue size #{queue.size}\n"


