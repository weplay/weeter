require 'optparse'

module Weeter
  class Cli

    def initialize(args)
      @configuration_file = "weeter.conf"
      args.options do |opts|
        opts.banner = "Usage: #{$0} [options]"
        opts.on("-c", "--configuration=filename", String,
                "Specifies an executable ruby file containing weeter configuration",
                "Default: weeter.conf") do |val|
          @configuration_file = val
        end
      end.parse!
    end

    def run
      load @configuration_file
      Weeter::Runner.new(Configuration.instance).start
    end

  end
end