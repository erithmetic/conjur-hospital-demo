require 'json'

def interpolate_namespace(string)
  string.gsub(/\$NS/, @ns.to_s)
end

When %r{I run `(.*)`( interactively)?} do |cmd, interactive|
  interpolated_command = interpolate_namespace cmd
  if interactive
    run_interactive interpolated_command
  else
    run_simple interpolated_command
  end
end

When %r{I enter the password "(.*)"} do |password|
  2.times do
    type password
  end
end

Then %r{the json output should have attribute "(.*)" with value "(.*)"} do |name, value|
  data = JSON.parse last_command_output
  data[name].should == interpolate_namespace(value)
end
