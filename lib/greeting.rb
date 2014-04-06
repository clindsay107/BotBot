require_relative 'trigger'

class Greeting < ResponseTrigger

	CANNED_RESPONSES = [
		"Hi",
		"Hello",
		"Hey",
		"Hola",
		"Sup",
		"Yo"
	]

	#pluck a random "greeting" string from cache, or create one
	def self.build_user_response(user)
		candidates = []

		$bot.msg_cache.each do |line|
			line = line.text
			if CANNED_RESPONSES.any?{ |r| line.downcase[r.downcase] }
				candidates << line
			end
		end
		if !candidates.empty?
			return candidates.sample
		end

		"#{CANNED_RESPONSES.sample} #{user}"
	end

end