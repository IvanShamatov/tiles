require 'pry'
require 'rbconfig'
require 'uh'


INPUT_MASK  = Uh::Events::SUBSTRUCTURE_REDIRECT_MASK
ROOT_MASK   = Uh::Events::PROPERTY_CHANGE_MASK |
              Uh::Events::SUBSTRUCTURE_REDIRECT_MASK |
              Uh::Events::SUBSTRUCTURE_NOTIFY_MASK |
              Uh::Events::STRUCTURE_NOTIFY_MASK

dpy = Uh::Display.new
dpy.open

def handle event
  send handler, event
end

def handle_key_press event
  puts "KEY PRESSED: #{event.key.to_sym}"
end

def handle_next_event
  handle @display.next_event
end

def handle_pending_events
  handle_next_event while @display.pending?
end

Display.on_error { fail 'OtherWMRunningError' }
dpy.listen_events INPUT_MASK
dpy.sync(false)
dpy.root.mask = ROOT_MASK

handle_next_event while dpy.pending?
