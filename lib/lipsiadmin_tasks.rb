$VERBOSE = nil
# Load Rails rakefile extensions
Dir["#{File.dirname(__FILE__)}/../tasks/*.rake"].each { |ext| load ext }