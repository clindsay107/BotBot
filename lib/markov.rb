require_relative 'trigger'

class Markov < ResponseTrigger

	def self.markov_response
		cache = $bot.msg_cache
		return "no messages in cache" if cache.length <= 1
		if cache.length < 50
			msg = cache[Random.rand(cache.length)]
			puts ">>> Returning #{msg.text}"
			return msg.text
		end
	end
end