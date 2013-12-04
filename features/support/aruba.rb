require 'aruba/api'
require 'aruba/cucumber/hooks'
require 'aruba/reporting'

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
