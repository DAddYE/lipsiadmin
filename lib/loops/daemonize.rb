module Lipsiadmin
  module Loops
    module Daemonize#:nodoc:
      def self.read_pid(pid_file)
        File.open(pid_file) do |f| 
          f.gets.to_i 
        end
      rescue Errno::ENOENT
        0
      end

      def self.check_pid(pid_file)
        pid = read_pid(pid_file)
        return false if pid.zero?
        if defined?(::JRuby)
          system "kill -0 #{pid} &> /dev/null"
          return $? == 0
        else 
          Process.kill(0, pid)
        end
        true
      rescue Errno::ESRCH, Errno::ECHILD, Errno::EPERM
        false
      end

      def self.create_pid(pid_file)
        if File.exist?(pid_file)
          puts "Pid file #{pid_file} exists! Checking the process..."
          if check_pid(pid_file)
            puts "Can't create new pid file because another process is runnig!"
            return false
          end
          puts "Stale pid file! Removing..."
          File.delete(pid_file)
        end

        puts "Creating pid file..."
        File.open(pid_file, 'w') do |f|
          f.puts(Process.pid)
        end

        return true
      end

      def self.daemonize(app_name)
        if defined?(::JRuby)
          puts "WARNING: daemonize method is not implemented for JRuby (yet), please consider using nohup."
          return
        end

        srand # Split rand streams between spawning and daemonized process
        fork && exit # Fork and exit from the parent

        # Detach from the controlling terminal
        unless sess_id = Process.setsid
          raise Daemons.RuntimeException.new('cannot detach from controlling terminal')
        end

        # Prevent the possibility of acquiring a controlling terminal
        trap 'SIGHUP', 'IGNORE'
        exit if pid = fork

        $0 = app_name if app_name

        Dir.chdir(LOOPS_ROOT) # Make sure we're in the working directory
        File.umask(0000) # Insure sensible umask

        return sess_id
      end    
    end
  end
end