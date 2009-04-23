module Lipsiadmin
  module Loops
    # This is the base class for make a simple loop with its own custom run method
    #
    # Examples:
    #
    #   class SimpleLoop < Lipsiadmin::Loops::Base
    #     def run
    #       debug(Time.now)
    #     end
    #   end
    #
    class Base#:nodoc:
      attr_accessor :name, :config, :logger
      
      # The initialize method, default we pass the logger
      def initialize(logger)
        self.logger = logger
      end

      # Ovveride this method for check dependencies
      def self.check_dependencies; end

      # Proxy logger calls to our logger
      [ :debug, :error, :fatal, :info, :warn ].each do |meth_name|
        class_eval <<-EVAL
          def #{meth_name}(message)
            logger.#{meth_name}("\#{Time.now}: loop[\#{name}/\#{Process.pid}]: \#{message}")
          end
        EVAL
      end

      def with_lock(entity_id, loop_id, timeout, entity_name = '')#:nodoc:
        entity_name = 'item' if entity_name.to_s.empty?

        debug("Locking #{entity_name} #{entity_id}")
        lock = LoopLock.lock(:entity_id => entity_id, :loop => loop_id.to_s, :timeout => timeout)
        unless lock
          warn("Race condition detected for the #{entity_name}: #{entity_id}. Skipping the item.")
          return
        end

        begin
          yield
        ensure
          debug("Unlocking #{entity_name} #{entity_id}")
          LoopLock.unlock(:entity_id => entity_id, :loop => loop_id.to_s)
        end
      end
    end
  end
end