Given %r{I am authorized with Conjur} do
  if File.exist?(File.join(ENV['HOME'], '.conjurrc'))
    step "I run `conjur authn:authenticate`"
  else
    puts <<-MSG
You must configure your Conjur credentials in ~/.conjurrc. For more information
see http://developer.conjur.net/guides/client-install.html
    MSG
    exit 1
  end
end
