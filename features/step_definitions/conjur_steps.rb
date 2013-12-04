require 'securerandom'

def interpolate_namespace(string)
  vars = string.scan /\$[A-Z_]+/

  vars.inject(string) do |str, var|
    str.gsub(var, ENV[var.sub('$', '')].to_s)
  end
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

When %r{I store the "(.*)" field as \$(.*)} do |field, var|
  ENV[var] = last_command_data[field]
end

When %r{I pipe in:} do |content|
  filename = SecureRandom.hex
  write_file filename, content

  #pipe_in_file filename not yet, daniel-san

  in_current_dir do
    File.open(filename, 'r').each_line do |line|
      _write_interactive(line)
    end
  end

  @interactive.stdin.close
end

Then %r{the json output should have attribute "(.*)" with value "(.*)"} do |name, value|
  last_command_data[name].should == interpolate_namespace(value)
end

Then %r{the output should be "(.*)"} do |text|
  last_command_output.should =~ /#{text}/
end
