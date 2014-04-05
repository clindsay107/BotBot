require_relative 'trigger'

class Markov < ResponseTrigger

	def self.markov_response
		cache = $bot.msg_cache
		return if cache.length <= 1
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
		max_length = Random.rand(5..15)
		if cache.last.text == $bot.nick
			chain = find_random(cache, clamp)
		else
			candidate = cache.last.text.split
			chain = candidate[0..Random.rand((candidate.length/clamp).abs+1)]
		end

		while chain.length < max_length do
			last_word = chain.last
			candidate = cache.sample.text.split

			(cache.length/2).times do 
				if candidate.include?(last_word)
					chain.concat(candidate[candidate.index(last_word)+1..-1])
					break
				end
				candidate = find_random(cache, clamp)
			end
			chain.concat(find_random(cache, clamp))
		end
		chain.join(" ")
	end

	#get a random string according to our clamp size
	def self.find_random(cache, clamp)
		candidate = cache.sample.text.split
		candidate[1..Random.rand((candidate.length/clamp).abs+1)]
	end
end