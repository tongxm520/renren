require 'drb'
require 'thread'

DRBSERVER = 'druby://localhost:9001'

module MasterControlProgram
  @scheduler = Mutex.new
  @process_by_id = {}

  def self.start_new_long_running_thingy
    @process_by_id.length.tap do |process_id|
      process = Process.new
      @process_by_id[process_id] = process
      process.go
    end
  end

  def self.status_for( process_id )
    if process = @process_by_id[process_id]
      process.status 
    end
  end

  def self.results_for( process_id )
    if process = @process_by_id[process_id]
      process.results 
    end
  end

  def self.processes
    @process_by_id.map do |id,process|
      if r = process.results
        { id: id, results: r }
      else
        { id: id, status: process.status }
      end
    end
  end
end

class MasterControlProgram::Process
  attr_reader :results

  def initialize
    @percent_done = 0.0
    @status = :starting
    @results = nil
    @data_accessor = Mutex.new
    @start = Time.now
  end

  def status
    # Ensure that nobody is changing the status while we read it
    @data_accessor.synchronize do
      { percent_done: @percent_done, status: @status }
    end
  end

  def go
    # silly simulation of process
    # will take on average 10 seconds to complete
    states = %w[ globbing_dirs aggregating_data undermixing_signals
                 damping_transients detecting_resonances
                 emptying_buffers computing_final_result ].map(&:to_sym)
    Thread.new do
      until @percent_done >= 1.0
        sleep rand * 1
        # Ensure that nobody is reading the status while we change it
        @data_accessor.synchronize do
          @status = states[ (states.length * @percent_done).floor ]
          @percent_done += rand * 0.03
        end
      end
      @data_accessor.synchronize do
        @percent_done = 1.0
        @status = :complete
      end
      @results = {
        signal_strength: [:excellent,:moderate,:poor].sample,
        score: rand * 100
      }
    end
  end
end

DRb.start_service( DRBSERVER, MasterControlProgram )
DRb.thread.join



