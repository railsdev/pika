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
                  :desc => "Pika config file",
                  :aliases => "-i",
                  :type => :string,
                  :default => File.join(Dir.pwd, "pika.conf")

    method_option :local_playlist,
                  :desc => "Local playlist file",
                  :aliases => "-f",
                  :type => :string

    def sync
      config_file = options[:input]
      playlist_file = options[:local_playlist]
      # playlist_file has precedence over pika config file
      if playlist_file and File.exists?(playlist_file)
        Operator.new.status(File.open(playlist_file).read, true)
      else
        if File.exist? config_file
          Operator.new.status(File.expand_path config_file)
        else
          abort "Couldn't find Pika config file '#{config_file}'"
        end
      end
    end

    default_task :sync

  end

end