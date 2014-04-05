require_relative 'trigger'

class Markov < ResponseTrigger

	def self.markov_response
		cache = $bot.msg_cache
		return "no messages in cache" if cache.length <= 1
		if cache.length < 5
			msg = cache.sample.text
			$log.info("Cache size under 30, returning #{msg}")
			return msg
		end
		build_chain(cache)
	end

	#build a random markov chain from the cache 
	def self.build_chain(cache)
		clamp = Random.rand(1..3)
		max_length = Random.rand(8..15)
		if cache.last.text == $bot.nick
			chain = find_random(cache, clamp)
		else
			chain = cache.last.text.split[1..clamp]
		end

		while chain.length < max_length do
			last_word = chain.last
			candidate = cache.sample.text.split

			#try for cache/2 times to find a "matching" candidate otherwise
			#just append a random string according to clamp length
			(cache.length/2).times do
				if candidate.include?(last_word)
					idx = candidate.index(last_word)+1
					chain.concat(candidate[idx..idx+clamp])
					break
				end
				candidate = cache.sample.text.split
			end
			chain.concat(find_random(cache, clamp))
		end
		chain.join(" ")
	end

	#get a random string according to our clamp size
	def self.find_random(cache, clamp)
		candidate = cache.sample.text.split
		if candidate.length < clamp
			find_random(cache, clamp)
		end
		start = Random.rand(clamp) - 1
		candidate = candidate[start..clamp]

		if candidate == []
			find_random(cache, clamp) 
		else
			return candidate
		end
	end
end