# frozen_string_literal: true

class XEventLogger
  def initialize(logger)
    @logger = logger
  end

  def log_event(xev)
    complement = case xev.type
                 when :key_press
                   "window: #{xev.window} key: #{xev.key} mask: #{xev.modifier_mask}"
                 when :map_request
                   "window: #{xev.window}"
                 end

    @logger.log [
      'XEvent',
      xev.type,
      xev.send_event ? 'SENT' : nil,
      complement
    ].compact.join ' '
  end

  def log_xerror(req, resource_id, msg)
    @logger.log("XERROR: #{resource_id} #{req} #{msg}")
  end
end
