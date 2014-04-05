require_relative 'trigger'

class Markov < ResponseTrigger

	def self.markov_response
		cache = $bot.msg_cache
		return if cache.length <= 1
		if cache.length < 10
			msg = cache.sample.text
			$log.info("Cache size under 10, returning #{msg}")
			return msg
		end
		build_chain(cache)
	end


	#build a random markov chain from the cache, using 1-4 string.
	#try to find ones that match on the last work of the latest link,
	#otherwise use a random string.
	def self.build_chain(cache)
		links = Random.rand(1..4)

		if cache.last == $bot.nick
			chain = cache.sample.text.split
		else
			chain = cache.last.text.split
		end

		while links > 0 do
			last_word = chain.last
			candidate = cache.sample.text.split

			(cache.length/2).times do 
				if candidate.include?(last_word)
					chain.concat(candidate[candidate.index(last_word)+1..-1])
					links -= 1
					break
				end
				candidate = cache.sample.text.split
			end

			chain.concat(cache.sample.text.split)
			links -= 1
		end
		$log.info("Chain built, returning #{chain.join(" ")}")
		chain.join(" ")
	end
end