# frozen_string_literal: true

class Tile
  include Uh::GeoAccessors

  attr_reader   :window
  attr_accessor :geo, :unmap_count

  def initialize(window, geo = nil)
    @window       = window
    @geo          = geo
    @visible      = false
    @unmap_count  = 0
  end

  def to_s
    "<#{name}> (#{wclass}) #{@geo} win: #{@window}"
  end

  def visible?
    @visible
  end

  def hidden?
    !visible?
  end

  def name
    @name ||= @window.name
  end

  def wclass
    @wclass ||= @window.wclass
  end

  def update_window_properties
    @wname  = @window.name
    @wclass = @window.wclass
  end

  def configure
    @window.configure @geo
    self
  end

  def moveresize
    @window.moveresize @geo
    self
  end

  def show
    @window.map
    @visible = true
    self
  end

  def hide
    @window.unmap
    @visible = false
    @unmap_count += 1
    self
  end

  def focus
    @window.raise
    @window.focus
    self
  end

  def kill
    if @window.icccm_wm_protocols.include? :WM_DELETE_WINDOW
      @window.icccm_wm_delete
    else
      @window.kill
    end
    self
  end

  def kill!
    window.kill
    self
  end
end
