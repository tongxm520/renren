require 'drb'

KEYWORDS=(1..10000).to_a
UNIT=100

class KeywordsDispatchServer
  def initialize
    @running=true
    @mutex=Mutex.new
    @curr_index=0
    @batch=0
  end

  def terminate
    @running = false
  end

  def ask_keywords
		assignment    
  end

  def assignment
    @mutex.synchronize do 
      if @curr_index>=KEYWORDS.size
        terminate
        return []
      end
      sleep(1+rand(5)) 
      result= KEYWORDS[@curr_index..(@curr_index+UNIT-1)]
      @batch+=1 
      @curr_index=@batch*UNIT
      result
    end
  end
end

DRb.start_service("druby://127.0.0.1:22422",KeywordsDispatchServer.new)
DRb.thread.join






