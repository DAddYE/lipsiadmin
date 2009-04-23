require 'yaml'

module Lipsiadmin
  
  # ==Simple background loops framework for rails
  # 
  # Loops is a small and lightweight framework for Ruby on Rails created to support simple 
  # background loops in your application which are usually used to do some background data processing 
  # on your servers (queue workers, batch tasks processors, etc).
  # 
  # Authors:: Alexey Kovyrin and Dmytro Shteflyuk
  # Comments:: This plugin has been created in Scribd.com for internal use.
  # 
  # == What tasks could you use it for?
  # 
  # Originally loops plugin was created to make our own loops code more organized. We used to have tens 
  # of different modules with methods that were called with script/runner and then used with nohup and 
  # other not so convenient backgrounding techniques. When you have such a number of loops/workers to 
  # run in background it becomes a nightmare to manage them on a regular basis (restarts, code upgrades, 
  # status/health checking, etc).
  # 
  # After a short time of writing our loops in more organized ways we were able to generalize most of the 
  # loops code so now our loops look like a classes with a single mandatory public method called *run*. 
  # Everything else (spawning many workers, managing them, logging, backgrounding, pid-files management, 
  # etc) is handled by the plugin it
  # 
  # 
  # == But there are dozens of libraries like this! Why do we need one more?
  # 
  # The major idea behind this small project was to create a deadly simple and yet robust framework to 
  # be able to run some tasks in background and do not think about spawning many workers, restarting 
  # them when they die, etc. So, if you need to be able to run either one or many copies of your worker or 
  # you do not want to think about re-spawning dead workers and do not want to spend megabytes of RAM on 
  # separate copies of Ruby interpreter (when you run each copy of your loop as a separate process 
  # controlled by monit/god/etc), then I'd recommend you to try this framework -- you'd like it.
  # 
  # 
  # == How to use?
  # 
  # Generate binary and configuration files by running 
  # 
  #   script/generate loops 
  # 
  # This will create the following list of files:
  # 
  #   script/loops        # binary file that will be used to manage your loops
  #   config/loops.yml    # example configuration file
  #   app/loops/simple.rb # REALLY simple loop example
  # 
  # Here is a simple loop scaffold for you to start from (put this file to app/loops/hello_world_loop.rb):
  # 
  #   class HelloWorldLoop < Lipsiadmin::Loops::Base
  #     def run
  #       debug("Hello, debug log!")
  #       sleep(config['sleep_period']) # Do something "useful" and make it configurable
  #       debug("Hello, debug log (yes, once again)!")
  #     end
  #   end
  # 
  # When you have your loop ready to use, add the following lines to your (maybe empty yet) config/loops.yml 
  # file:
  # 
  #   hello_world:
  #     sleep_period: 10
  # 
  # This is it! To start your loop, just run one of the following commands:
  # 
  #   # Generates: list all configured loops:
  #   $ script/loops -L
  #   
  #   # Generates: run all enabled (actually non-disabled) loops in foreground:
  #   $ script/loops -a
  #   
  #   # Generates: run all enabled loops in background:
  #   $ script/loops -d -a
  #   
  #   # Generates: run specific loop in background:
  #   $ ./script/loops -d -l hello_world
  #   
  #   # Generates: all possible options:
  #   $ ./script/loops -h
  # 
  # 
  # == How to run more than one worker?
  # 
  # If you want to have more than one copy of your worker running, that is as simple as adding one 
  # option to your loop configuration:
  # 
  #   hello_world:
  #     sleep_period: 10
  #     workers_number: 1  
  # 
  # This _workers_number_ option would say loops manager to spawn more than one copy of your loop 
  # and run them in parallel. The only thing you'd need to do is to think about concurrent work of 
  # your loops. For example, if you have some kind of database table with elements you need to 
  # process, you can create a simple database-based locks system or use any memcache-based locks.
  # 
  # 
  # == There is this <tt>workers_engine</tt> option in config file. What it could be used for?
  # 
  # There are two so called "workers engines" in this plugin: <tt>fork</tt> and <tt>thread</tt>. They're used 
  # to control the way process manager would spawn new loops workers: with <tt>fork</tt> engine we'll 
  # load all loops classes and then fork ruby interpreter as many times as many workers we need. 
  # With <tt>thread</tt> engine we'd do Thread.new instead of forks. Thread engine could be useful if you 
  # are sure your loop won't lock ruby interpreter (it does not do native calls, etc) or if you 
  # use some interpreter that does not support forks (like jruby).
  # 
  # Default engine is <tt>fork</tt>.
  # 
  # 
  # == What Ruby implementations does it work for?
  # 
  # We've tested and used the plugin on MRI 1.8.6 and on JRuby 1.1.5. At this point we do not support 
  # demonization in JRuby and never tested the code on Ruby 1.9. Obviously because of JVM limitations 
  # you won't be able to use +fork+ workers engine in JRuby, but threaded workers do pretty well.
  #
  module Loops
    
    class << self
      
      # Set/Return the main config
      def config
        @@config
      end
      
      # Set/Return the loops config
      def loops_config
        @@loops_config
      end

      # Set/Return the global config
      def global_config
        @@global_config
      end
      
      # Load the yml config file, default config/loops.yml
      def load_config(file)
        @@config = YAML.load_file(file)
        @@global_config = @@config['global']
        @@loops_config = @@config['loops']

        @@logger = create_logger('global', global_config)
      end
      
      # Start loops, default :all
      def start_loops!(loops_to_start = :all)
        @@running_loops = []
        @@pm = Loops::ProcessManager.new(global_config, @@logger)

        # Start all loops
        loops_config.each do |name, config|
          next if config['disabled']
          next unless loops_to_start == :all || loops_to_start.member?(name)
          klass = load_loop_class(name)
          next unless klass

          start_loop(name, klass, config) 
          @@running_loops << name
        end

        # Do not continue if there is nothing to run
        if @@running_loops.empty?
          puts "WARNING: No loops to run! Exiting..."
          return
        end

        # Start monitoring loop
        setup_signals
        @@pm.monitor_workers

        info "Loops are stopped now!"
      end

    private

      # Proxy logger calls to the default loops logger
      [ :debug, :error, :fatal, :info, :warn ].each do |meth_name|
        class_eval <<-EVAL
          def #{meth_name}(message)
            LOOPS_DEFAULT_LOGGER.#{meth_name} "\#{Time.now}: loops[RUNNER/\#{Process.pid}]: \#{message}"
          end
        EVAL
      end

      def load_loop_class(name)
        begin
          klass_file = LOOPS_ROOT + "/app/loops/#{name}.rb" 
          debug "Loading class file: #{klass_file}"
          require(klass_file)
        rescue Exception
          error "Can't load the class file: #{klass_file}. Worker #{name} won't be started!"
          return false
        end

        klass_name = "#{name}".classify
        klass = klass_name.constantize rescue nil

        unless klass
          error "Can't find class: #{klass_name}. Worker #{name} won't be started!"
          return false
        end

        begin
          klass.check_dependencies
        rescue Exception => e
          error "Loop #{name} dependencies check failed: #{e} at #{e.backtrace.first}"
          return false
        end

        return klass
      end

      def start_loop(name, klass, config)
        puts "Starting loop: #{name}"
        info "Starting loop: #{name}"
        info " - config: #{config.inspect}"

        @@pm.start_workers(name, config['workers_number'] || 1) do
          debug "Instantiating class: #{klass}"
          looop = klass.new(create_logger(name, config))
          looop.name = name
          looop.config = config

          debug "Starting the loop #{name}!"
          fix_ar_after_fork
          looop.run
        end
      end

      def create_logger(loop_name, config)
        config['logger'] ||= (global_config['logger'] || 'default')

        return LOOPS_DEFAULT_LOGGER if config['logger'] == 'default'
        return Logger.new(STDOUT)   if config['logger'] == 'stdout'
        return Logger.new(STDERR)   if config['logger'] == 'stderr'

        config['logger'] = File.join(LOOPS_ROOT, config['logger']) unless config['logger'] =~ /^\//
        Logger.new(config['logger'])

      rescue Exception => e
        message = "Can't create a logger for the #{loop_name} loop! Will log to the default logger!"
        puts "ERROR: #{message}"

        message << "\nException: #{e} at #{e.backtrace.first}"
        error(message)

        return LOOPS_DEFAULT_LOGGER
      end

      def setup_signals
        trap('TERM') {
          warn "Received a TERM signal... stopping..."
          @@pm.stop_workers!
        }

        trap('INT') { 
          warn "Received an INT signal... stopping..."
          @@pm.stop_workers!
        }

        trap('EXIT') { 
          warn "Received a EXIT 'signal'... stopping..."
          @@pm.stop_workers!
        }
      end

      def fix_ar_after_fork
        ActiveRecord::Base.clear_active_connections!
        ActiveRecord::Base.verify_active_connections!
      end
      
    end
  end
end

require 'loops/process_manager'
require 'loops/base'