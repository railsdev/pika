require 'fileutils'

module Pika

  class App < Thor

    map %w{-V --version} => :version

    desc "version", "Displays the program's version"

    def version
      say "Pika version #{VERSION}"
    end

    desc "sync", "Show the status of the current playlist and update it"

    method_option :input,
                  :desc => "Playlist file",
                  :aliases => "-i",
                  :type => :string,
                  :default => File.join(Dir.pwd, "pika.conf")

    def sync
      current_directory = Dir.pwd
      file = options[:input]
      if File.exist? file
        Operator.new.status(File.expand_path file)
      else
        abort "Couldn't find the file '#{file}'"
      end
    end

  end

end