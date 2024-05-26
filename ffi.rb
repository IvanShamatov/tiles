require 'pry'
require 'ffi'

module Xlib
  extend FFI::Library
  ffi_lib 'X11'

  attach_function :XOpenDisplay, [:string], :pointer
  attach_function :XDefaultRootWindow, [:pointer], :ulong
  attach_function :XSelectInput, [:pointer, :ulong, :long], :int
  attach_function :XNextEvent, [:pointer, :pointer], :int
  attach_function :XMapWindow, [:pointer, :ulong], :int
  attach_function :XUnmapWindow, [:pointer, :ulong], :int
  attach_function :XGetWindowAttributes, [:pointer, :ulong, :pointer], :int
  attach_function :XMoveResizeWindow, [:pointer, :ulong, :int, :int, :uint, :uint], :int

  class XWindowAttributes < FFI::Struct
    layout :x, :int,
           :y, :int,
           :width, :int,
           :height, :int,
           :border_width, :int,
           :depth, :int,
           :visual, :pointer,
           :root, :ulong,
           :class, :int,
           :bit_gravity, :int,
           :win_gravity, :int,
           :backing_store, :int,
           :backing_planes, :ulong,
           :backing_pixel, :ulong,
           :save_under, :int,
           :colormap, :ulong,
           :map_installed, :int,
           :map_state, :int,
           :all_event_masks, :ulong,
           :your_event_mask, :ulong,
           :do_not_propagate_mask, :ulong,
           :override_redirect, :int,
           :screen, :pointer
  end

  class XEvent < FFI::Union
    layout :type, :int,
           :xmaprequest, [:char, 24],   # Placeholder for different event types
           :xconfigurerequest, [:char, 24],
           :xunmap, [:char, 24],
           :xdestroywindow, [:char, 24],
           :xkeypress, [:char, 24],
           :xbuttonpress, [:char, 24]
  end

  module Constants
    SubstructureRedirectMask = 0x02000000
    SubstructureNotifyMask = 0x04000000
    KeyPressMask = 0x00000001
    ButtonPressMask = 0x00000004
    EnterWindowMask = 0x00000400
    LeaveWindowMask = 0x00000800
    FocusChangeMask = 0x00020000

    MapRequest = 20
    ConfigureRequest = 23
    MapNotify = 19
    UnmapNotify = 18
    DestroyNotify = 17
    KeyPress = 2
    ButtonPress = 4
  end
end

display = Xlib.XOpenDisplay(nil)
if display.null?
  puts "Cannot open display"
  exit 1
end

root_window = Xlib.XDefaultRootWindow(display)
puts "Root window ID: #{root_window}"

# Отладка: Проверьте, есть ли другой клиент, уже захвативший управление окнами
window_attrs = FFI::MemoryPointer.new(:long)
status = Xlib.XGetWindowAttributes(display, root_window, window_attrs)
puts "XGetWindowAttributes status: #{status}"
puts "Window attributes: #{window_attrs.read_long}"

# Выбираем события, которые нас интересуют
event_mask = Xlib::Constants::SubstructureRedirectMask | Xlib::Constants::SubstructureNotifyMask | Xlib::Constants::KeyPressMask | Xlib::Constants::ButtonPressMask
status = Xlib.XSelectInput(display, root_window, event_mask)
puts "XSelectInput status: #{status}"
if status != 0
  puts "XSelectInput failed"
  exit 1
end

windows = {}

# if status != 0
#   puts "XSelectInput failed"
#   exit 1
# end

# Xlib.XQueryTree(display, root, root_ptr, parent_ptr, children_ptr, nchildren_ptr)
# children = children_ptr.read_pointer.read_array_of_ulong(nchildren_ptr.read_uint)

# children.each do |window|
#   name_ptr = FFI::MemoryPointer.new(:pointer)
#   if Xlib.XFetchName(display, window, name_ptr) != 0
#     name = name_ptr.read_pointer.read_string
#     puts "Window ID: #{window}, Name: #{name}"
#   end
# end

# Xlib.XCloseDisplay(display)

def handle_map_request(event)
  puts "MAP CALLED: #{event}"
  window = event[:xmaprequest][:window]
  Xlib.XMapWindow(display, window)
  # Добавьте окно в ваш список окон и выполните раскладку
end

def handle_configure_request(event)
  puts "RECONFIGURE CALLED: #{event}"
  window = event[:xconfigurerequest][:window]
  x = event[:xconfigurerequest][:x]
  y = event[:xconfigurerequest][:y]
  width = event[:xconfigurerequest][:width]
  height = event[:xconfigurerequest][:height]
  border_width = event[:xconfigurerequest][:border_width]

  # Обработайте запрос на изменение конфигурации окна
  Xlib.XMoveResizeWindow(display, window, x, y, width, height)
end

def handle_unmap_notify(event)
  puts "HIDE CALLED: #{event}"
  window = event[:xunmap][:window]
  # Удалите окно из вашего списка окон и выполните раскладку
end

def handle_destroy_notify(event)
  puts "DESTROY CALLED: #{event}"
  window = event[:xdestroywindow][:window]
  # Удалите окно из вашего списка окон и выполните раскладку
end

def handle_key_press(event)
  puts "KEY PRESSED: #{event}"
end

def handle_button_press(event)
  puts "MOUSE CLICKED: #{event}"
end

loop do
  event = Xlib::XEvent.new
  Xlib.XNextEvent(display, event)

  case event[:type]
  when Xlib::Constants::MapRequest
    handle_map_request(event)
  when Xlib::Constants::ConfigureRequest
    handle_configure_request(event)
  when Xlib::Constants::UnmapNotify
    handle_unmap_notify(event)
  when Xlib::Constants::DestroyNotify
    handle_destroy_notify(event)
  when Xlib::Constants::KeyPress
    handle_key_press(event)
  when Xlib::Constants::ButtonPress
    handle_button_press(event)
  end
end
