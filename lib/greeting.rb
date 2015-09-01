require_relative 'trigger'

class Greeting < ResponseTrigger

	CANNED_RESPONSES = [
		"hi", "hello", "hey", "hola", "sup", "yo", "wsup", "ayy", "shut up"
	]

	def initialize(trigger)
		super(trigger, true)
	end

	def proc_response
		Proc.new { build_user_response($bot.msg_cache.last.nickname) }
	end

	# Pluck a random "greeting" string from cache, or create one
	def build_user_response(user)
		candidates = []

		# If a line in our cache contains any of the canned_responses, add it as candidate
		$bot.msg_cache.each do |line|
			if CANNED_RESPONSES.any?{ |r| /(^|\s)#{r}($|\s)/ =~ line.text }
				candidates << line.text if !candidates.include?(line)
			end
		end

		if candidates.empty?
			return "#{CANNED_RESPONSES.sample} #{user}"
		end

		candidates.sample
	end

end
