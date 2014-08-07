# Copyright (c) 2013-2014 Irrational Industries Inc. d.b.a. Nitrous.IO
# This software is licensed under the [BSD 2-Clause license](https://raw.github.com/nitrous-io/autoparts/master/LICENSE).

module Autoparts
  module Commands
    class Restart
      def initialize(args, options)
        if args.empty?
          abort <<-EOS.unindent
            Usage: parts restart PACKAGE...
            Example: parts restart postgresql
          EOS
        end
        begin
          args.each do |package_name|
            unless Package.installed? package_name
              raise PackageNotInstalledError.new package_name
            end
            package = Package.factory(package_name)
            if package.respond_to?(:start) && package.respond_to?(:stop)
              puts "=> Stopping #{package_name}..."
              package.stop if package.running?
              puts "=> Starting #{package_name}..."
              package.start
              puts "=> Restarted: #{package_name}"
            else
              abort "parts: #{package_name} does not support this operation."
            end
          end
        rescue => e
          abort "parts: ERROR: #{e}\nAborting!"
        end
      end
    end
  end
end
