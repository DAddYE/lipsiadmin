require 'loops/worker'
require 'loops/worker_pool'

module Lipsiadmin
  module Loops
    class ProcessManager#:nodoc:
      attr_reader :logger

      def initialize(config, logger)
        @config = {
          'poll_period' => 1,
          'workers_engine' => 'fork'
        }.merge(config)

        @logger = logger
        @worker_pools = {}
        @shutdown = false
      end

      def start_workers(name, number, &blk)
        raise "Need a worker block!" unless block_given?

        logger.debug("Creating a workers pool of #{number} workers for #{name} loop...")
        @worker_pools[name] = Lipsiadmin::Loops::WorkerPool.new(name, logger, @config['workers_engine'], &blk)
        @worker_pools[name].start_workers(number)
      end

      def monitor_workers
        setup_signals

        logger.debug('Starting workers monitoring code...')
        loop do
          logger.debug('Checking workers\' health...')
          @worker_pools.each do |name, pool|
            break if @shutdown
            pool.check_workers
          end

          break if @shutdown
          logger.debug("Sleeping for #{@config['poll_period']} seconds...")
          sleep(@config['poll_period']) 
        end
      ensure
        unless wait_for_workers(10)
          logger.debug("Some workers are still alive after 10 seconds of waiting. Killing them...")
          stop_workers(true)
          wait_for_workers(5)
        end
      end

      def setup_signals
        # Zombie rippers
        trap('CHLD') {}
        trap('EXIT') {}
      end

      def wait_for_workers(seconds)
        seconds.times do
          logger.debug("Shutting down... waiting for workers to die (we have #{seconds} seconds)...")
          running_total = 0

          @worker_pools.each do |name, pool|
            running_total += pool.wait_workers
          end

          if running_total.zero?
            logger.debug("All workers are dead. Exiting...")
            return true
          end

          logger.debug("#{running_total} workers are still running! Sleeping for a second...")
          sleep(1)
        end    

        return false
      end

      def stop_workers(force = false)
        return unless start_shutdown || force
        logger.debug("Stopping workers#{force ? '(forced)' : ''}...")

        # Termination loop
        @worker_pools.each do |name, pool|
          pool.stop_workers(force)
        end
      end

      def stop_workers!
        return unless start_shutdown
        stop_workers(false)
        sleep(1)
        stop_workers(true)
      end

      def start_shutdown
        return false if @shutdown
        @shutdown = true
      end
    end
  end
end