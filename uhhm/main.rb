# frozen_string_literal: true

require 'uh'
require 'logger'
require_relative 'runner'
require_relative 'x_event_logger'
require_relative 'events'
require_relative 'layout'
require_relative 'manager'
require_relative 'tile'
require_relative 'stack'

OtherWMRunningError = Class.new(RuntimeError)
$logger = Logger.new($stdout)
Runner.run
