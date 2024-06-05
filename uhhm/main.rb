# frozen_string_literal: true

require 'uh'
require 'logger'
require 'pry'
require_relative 'runner'
require_relative 'x_event_logger'
require_relative 'events'
require_relative 'layouts/all'
require_relative 'manager'
require_relative 'tile'
require_relative 'stack'

OtherWMRunningError = Class.new(RuntimeError)
$logger = Logger.new($stdout)
Runner.run
