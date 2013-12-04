require 'aruba/api'
require 'aruba/cucumber/hooks'
require 'aruba/reporting'

require 'json'

World(Aruba::Api)

Before do
  @aruba_timeout_seconds = 10
end

def last_command
  get_process(@commands.last)
end

def last_command_output
  last_command.output.rstrip
end

def last_command_data
  JSON.parse last_command_output
end
