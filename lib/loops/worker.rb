module Lipsiadmin
  module Loops
    class Worker#:nodoc:
      attr_reader :logger
      attr_reader :name
      attr_reader :pid

      def initialize(name, logger, engine, &blk)
        raise "Need a worker block!" unless block_given?

        @name = name
        @logger = logger
        @engine = engine    
        @worker_block = blk

        @shutdown = false
      end

      def shutdown?
        @shutdown
      end

      def run
        return if shutdown?
        if @engine == 'fork'
          @pid = Kernel.fork do
            $0 = "loop worker: #{@name}\0"
            @pid = Process.pid
            @worker_block.call
            exit(0)
          end
        elsif @engine == 'thread'
          @thread = Thread.start do
            @worker_block.call
          end
        else
          raise "Invalid engine name: #{@engine}"
        end
      rescue Exception => e
        logger.error("Exception from worker: #{e} at #{e.backtrace.first}")
      end

      def running?(verbose = false)
        return false if shutdown?
        if @engine == 'fork'
          return false unless @pid
          begin
            Process.waitpid(@pid, Process::WNOHANG)
            res = Process.kill(0, @pid)
            logger.debug("KILL(#{@pid}) = #{res}") if verbose
            return true
          rescue Errno::ESRCH, Errno::ECHILD, Errno::EPERM => e
            logger.error("Exception from kill: #{e} at #{e.backtrace.first}") if verbose
            return false
          end
        elsif @engine == 'thread'
          @thread && @thread.alive?
        else
          raise "Invalid engine name: #{@engine}"
        end
      end

      def stop(force = false)
        @shutdown = true
        if @engine == 'fork'
          begin
            sig = force ? 'SIGKILL' : 'SIGTERM'
            logger.debug("Sending #{sig} to ##{@pid}")
            Process.kill(sig, @pid)
          rescue Errno::ESRCH, Errno::ECHILD, Errno::EPERM=> e
            logger.error("Exception from kill: #{e} at #{e.backtrace.first}")
          end
        elsif @engine == 'thread'
          force && !defined?(::JRuby) ? @thread.kill! : @thread.kill
        else
          raise "Invalid engine name: #{@engine}"
        end
      end
    end
  end
end
