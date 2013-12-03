When %r{I save the generated id in \$NS} do
  ENV['NS'] = all_output.split("\n").last
end
