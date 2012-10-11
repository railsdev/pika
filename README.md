# Pika

Pika is a command line tool to manage the download and the synchronization of _xspi_ playlists. You can install it as a global gem so that the command is available in all the system.

## Installation

From any directory type:

`gem install pika`

Done! Easy isn't it?

## Usage

Pika can synchronize playlist through both local or remote playlist files. You can place playlist or configuration files in a separate folders so you can synchronize them independently.

### Local playlist file

Let's suppose you want synchronize a local playlist file called `playlist.xspf`.
Put the file inside a folder and `cd` inside that folder. Now simply launch

`pika`

and the synchronization should begin. Pika looks by default for a file in the current directory called `playlist.xspf`. If you need to customize the name of the _xspf_ file being used, use the `-f` parameter:

`pika -f my_playlist.xspf`

### Remote playlist file

To use a remote _xspf_ file, create (in a new directory) a file named `pika.conf` and paste the url of the playlist in the first line of this file. Now to launch the synchronization simply type:

`pika`

and the synchronization should begin. Again `pika` looks by default for a file called `pika.conf`. If you need to customize the config file name, use the -i parameter:

`pika -i my_conf.conf`

## Changelog

You can see the changelog [here](https://github.com/davide-targa/pika/blob/master/CHANGELOG.md)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

This rubygem was developed by [Davide Targa](http://www.davidetarga.it).