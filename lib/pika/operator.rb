module Pika

  class Operator
  	require 'open-uri'
    attr_reader :remote_tracks_urls, :missing_files_names, :missing_files_urls, :config_file

    def status(file, local = false)
      @config_file = file
      if local
        puts "Using local playlist file"
      else
        puts "Using config file: #{config_file}"
        @config_file = fetch_playlist
      end
      initialize_locals(config_file)
      puts "#{pluralize(missing_files_names.length, "tracks")} to download".yellow
      extract_missing_files_urls
      if missing_files_urls
        begin
          print "Download missing files? [Yn]: "
          input = STDIN.gets
        end while not ["Y", "y", "N", "n"].include? input.chomp
        if positive?(input.chomp)
          puts "Fetching files information. This may take some time..."
          puts
          download_missing_files
          puts @remote_tracks_urls.inspect
          puts remote_tracks_urls.inspect
        end
      else
        puts "Nothing to do here.".green
        puts "Terminating."
      end
    end

    private

    def download_missing_files
      puts "### DOWNLOADING FILES ###".green
      puts
      missing_files_urls.each_with_index do |file, idx|
        filename = file.split("/").last
        puts "(#{idx + 1}/#{missing_files_urls.length}) Downloading: " + file.green + " => " + filename.green + " - " + ("%5.2f" %estimate_file_size(URI(file))) + " MB"
        begin
          file_data = open(file) {|f| f.read }
          open("#{idx}.mp3", "wb") do |fi|
            fi.write(file_data)
          end
        rescue OpenURI::HTTPError
          puts "Failed for #{file}"
        end
        puts
      end
      puts "Done.".green
    end

    def estimate_file_size(url)
      response = nil
      Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
        response = http.head(url.path)
      end
      response['content-length'].to_i / 1024.0 / 1024
    end

    def fetch_playlist
      url = URI.parse(File.open(config_file).read)
      puts "Fetching playlist information from: #{url}"
      puts url.inspect
      response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') { |http| http.request(Net::HTTP::Get.new(url.path)) }
      response.body.to_s
    end

    def initialize_locals(content = nil)
      if content
        x = XSPF.new(content)
      else
        x = XSPF.new(fetch_playlist)
      end
      pl = XSPF::Playlist.new(x)
      tl = XSPF::Tracklist.new(pl)
      print "#{pluralize(tl.tracks.count, "track")} found".green + ", "
      tl.tracks.each do |track|
        (@remote_tracks_urls ||= []) << track.location
      end
       
      @missing_files_names = @remote_tracks_urls.map do |track_url| 
        if track_url =~ /soundcloud/
          id = URI(track_url).path[/(\d+)(?:\/)/]
          id.delete!("/")
          id
        else
          URI(track_url).path.split("/").last 
        end
      end - files_in_current_directory
    end

    def positive?(string)
      ["Y", "y"].include?(string) ? true : false
    end

    def negative?(string)
      ["N", "n"].include?(string) ? true : false
    end

    def pluralize(count, singular, plural = nil)
      "#{count || 0} " + ((count == 1 || count =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
    end

    def files_in_current_directory
      Dir['**/*']
    end

    def extract_missing_files_urls
      return [] if missing_files_names.empty?
      missing_files_names.each do |mf|
        (@missing_files_urls ||= []) << remote_tracks_urls.select { |el| el =~ /#{mf}/ }
      end
      @missing_files_urls.flatten!
    end

  end

end
