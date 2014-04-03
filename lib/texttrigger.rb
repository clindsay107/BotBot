#An object that will respond to a given trigger regular expression
#and reply with a string

class TextTrigger

  #here I want to add the response to a response array (in the DB) if a
  #trigger already exists. Also add the funcitonality to remove a specific
  #response for a trigger, unless it is the last remaining response for that
  #trigger, in which case remove the trigger from the DB entirely

  def initialize(trigger, response, privatemsg = false, user = nil)
    @trigger = trigger
    @matcher = /#{trigger}/
    @private = privatemsg
    @user = user if @private
    @response = response
  end

  def matched?(str)
    @matcher.match(str) ? true : false
  end

end