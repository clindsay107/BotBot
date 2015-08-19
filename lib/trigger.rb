class ResponseTrigger

  # Here I want to add the response to a response array (in the DB) if a
  # Trigger already exists. Also add the funcitonality to remove a specific
  # Response for a trigger, unless it is the last remaining response for that
  # Trigger, in which case remove the trigger from the DB entirely

  attr_reader :response, :matcher, :implicit

  # `implicit` value means a command that does not require a !bang and can be
  # matched anywhere in the string, not only at the beginning
  def initialize(trigger, implicit = false)
    @implicit = implicit
    @matcher = build_matcher(trigger)
    @response = proc_response()
  end

  def name
    "trigger.#{self.class.name}"
  end

  # A method that must be overridden by all inheriting subclasses. It should
  # always return a Proc of a response (usually a method call) so that it can
  # be called at a later time in Irc#fire_triggers
  def proc_response
    raise 'Subclasses MUST override to_proc method!'
  end

  # When building a matcher from a string, you MUST double escape backward slashes
  # or they will be ignored!
  def build_matcher(trigger)
    if trigger[0] == "/" && trigger[-1] == "/"
      trigger = trigger[1..-2]
    end
      @implicit ? /(^|\s)#{trigger}($|\s)/ : /^#{trigger}($|\s)/
  end

  # If response is a proc, then call it. Otherwise it is just a vanilla string
  # and we can return it as-is
  def respond
    if @response.class.name == "Proc"
      return @response.call
    end
    @response
  end

  # BotBot uses ! syntax. Feel free to change this to anything you wish.
  def matched?(str)
    return false if (!@implicit && str[0] != "!")
    if (self.matcher =~ str) != nil
      $bot.last_match = $~
      $log.info("/#{@matcher.source}/ matched #{str}")
      return true
    end
    false
  end

end
