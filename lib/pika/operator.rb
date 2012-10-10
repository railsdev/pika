module Pika

  class Operator

    attr_reader :remote_tracks_urls, :missing_files_names, :missing_files_urls, :config_file, :missing_files_total_size

    def status(file)
      @config_file = file
      puts "Using config file: #{config_file}"
      initialize_locals
      puts "#{pluralize(missing_files_names.length, "tracks")} to download".yellow
      extract_missing_files_urls
      if missing_files_urls
        begin
          print "Download missing files? [Yn]: "
          input = STDIN.gets
        end while not ["Y", "y", "N", "n"].include? input.chomp
        if positive?(input.chomp)
          print_info_table
          puts
          download_missing_files
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
        puts "(#{idx + 1}/#{missing_files_urls.length}) Downloading: " + file.green + " => " + filename.green
        `curl -# -o #{filename} "#{file}"`
        puts
      end
      puts "Done.".green
    end

    def print_info_table
      rows = []
      @missing_files_total_size = 0
      missing_files_urls.each do |file_url|
        file_size = estimate_file_size(URI(file_url))
        @missing_files_total_size += file_size
        rows << [file_url.split("/").last, ("%5.2f" %file_size).green]
        rows << :separator unless file_url == missing_files_urls.last
      end
      rows << :separator
      rows << ["Total size".red, ("%8.2f" %missing_files_total_size.to_s).red]
      puts Terminal::Table.new :headings => ['File name'.green, 'File size (MB)'.green], :rows => rows, :style => {:padding_left => 3, :padding_right => 3}
    end

    def estimate_file_size(url)
      response = nil
      Net::HTTP.start(url.host, url.port) do |http|
        response = http.head(url.path)
      end
      response['content-length'].to_i / 1024.0 / 1024
    end

    def fetch_playlist
      url = URI.parse(File.open(config_file).read)
      puts "Fetching playlist information from: #{url}"
      response = Net::HTTP.new(url.host, url.port).start { |http| http.request(Net::HTTP::Get.new(url.path)) }
      response.body.to_s
    end

    def initialize_locals
      x = XSPF.new(fetch_playlist)
      pl = XSPF::Playlist.new(x)
      tl = XSPF::Tracklist.new(pl)
      print "#{pluralize(tl.tracks.count, "track")} found".green + ", "
      tl.tracks.each do |track|
        (@remote_tracks_urls ||= []) << track.location
      end
      @missing_files_names = @remote_tracks_urls.map { |track_url| URI(track_url).path.split("/").last } - files_in_current_directory
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
        (@missing_files_urls ||= []) << remote_tracks_urls.select { |el| el.split("/").last == mf }
      end
      @missing_files_urls.flatten!
    end

  end

end