module Lipsiadmin
  module Loops
    class WorkerPool#:nodoc:
      attr_reader :logger
      attr_reader :name

      def initialize(name, logger, engine, &blk)
        @name = name
        @logger = logger
        @worker_block = blk
        @shutdown = false
        @engine = engine
        @workers = []
      end

      def start_workers(number)
        logger.debug("Creating #{number} workers for #{name} loop...")
        number.times do 
          @workers << Lipsiadmin::Loops::Worker.new(name, logger, @engine, &@worker_block)
        end
      end

      def check_workers
        logger.debug("Checking loop #{name} workers...")
        @workers.each do |worker|
          next if worker.running? || worker.shutdown?
          logger.debug("Worker #{worker.name} is not running. Restart!")
          worker.run
        end
      end

      def wait_workers
        running = 0
        @workers.each do |worker|
          next unless worker.running?
          running += 1
          logger.debug("Worker #{name} is still running (#{worker.pid})")
        end
        return running
      end

      def stop_workers(force)
        return if @shutdown
        @shutdown = false
        logger.debug("Stopping loop #{name} workers...")
        @workers.each do |worker|
          next unless worker.running?
          worker.stop(force)
        end
      end
    end
  end
end
