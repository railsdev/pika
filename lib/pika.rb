require 'thor'
require 'net/http'
require 'xspf'
require 'active_support/all'
require 'colored'
require 'terminal-table'

require 'pika/version'
require 'pika/app'
require 'pika/operator'
require 'pry'
module Pika
  App.start
end
