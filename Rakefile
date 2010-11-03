require 'rake'

namespace :weeter do
  desc "Run weeter"
  task :run do
    require 'lib/weeter'
    raise "You must specify a URL to receive tweets with URL=..." unless ENV['URL']
    Weeter::Runner.new(ENV['URL'])
  end
end