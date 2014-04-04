class Trigger

  def name
    "trigger.#{self.class.name}"
  end

end

#An object that will respond to a given trigger regular expression
#and reply with a string

class ResponseTrigger < Trigger

  #here I want to add the response to a response array (in the DB) if a
  #trigger already exists. Also add the funcitonality to remove a specific
  #response for a trigger, unless it is the last remaining response for that
  #trigger, in which case remove the trigger from the DB entirely

  attr_reader :response

  def initialize(trigger, response, implicit = false)
    build_matcher(trigger)
    @response = response
    @implicit = implicit
  end

  def build_matcher(trigger)
    if trigger[0] == "/" && trigger[-1] == "/"
      trigger = trigger[1..-2]
      @matcher = /#{trigger}/
    else
      @matcher = /(^|\s)#{trigger}($|\s)/
    end
  end

  def matched?(str)
    !@matcher.match(str).nil?
  end

end