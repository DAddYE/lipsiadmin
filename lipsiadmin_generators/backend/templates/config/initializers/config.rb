require 'ostruct'
require 'yaml'

config = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/config.yml"))
env_config = config.send(RAILS_ENV)
config.common.update(env_config) unless env_config.nil?
::AppConfig = OpenStruct.new(config.common)