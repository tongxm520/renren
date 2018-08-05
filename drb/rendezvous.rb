require 'monitor'

class Rendezvous
  include MonitorMixin

  def initialize
    super
		@arrived_cond = new_cond
		@removed_cond = new_cond
		@box = nil
		@arrived = false
  end

  def send(obj)
		synchronize do
			#while @arrived
			#	@removed_cond.wait
			#end
      @removed_cond.wait_while { @arrived }
			@arrived = true
			@box = obj
			@arrived_cond.broadcast
			@removed_cond.wait
		end
	end

  def recv
		synchronize do
			@arrived_cond.wait_until { @arrived }
			@arrived = false
			@removed_cond.broadcast
			return @box
		end
	end
end

=begin
There are two condition variables, @arrived_cond and @removed_cond . @box stores
the newly arrived messages, and @arrived is a flag to indicate that the new
message has arrived. @arrived_cond is a condition variable to notify when a new
message has arrived when the send method is called. @removed_cond is a condition variable to notify when a message is removed. This is called when @box receives data.
=end


