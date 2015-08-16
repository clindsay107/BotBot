require_relative 'trigger'

class Markov < ResponseTrigger

	def self.markov_response(random = false)
		@cache = $bot.msg_cache
		return if @cache.length <= 2
		if @cache.length < 10
			msg = @cache.sample.text
			$log.info("Cache size under 10, returning #{msg}")
			return msg
		end

		if random
			seed = [@cache.sample.text.split.last]
			build_chain(seed)
		else
			build_chain
		end

	end

	def self.random_markov
		markov_response(true)
	end

	#build a random markov chain from the cache, using 3-15 string.
	#try to find ones that match on the last work of the latest link,
	#otherwise use a random string.
	def build_chain(seed = nil)
		links = Random.rand(3..15)

		chain = seed || create_seed

		while links > 0 do
			if (links == 1)
				chain.concat(final_word)
			else
				candidate = get_candidate

				temp = get_matching_candidate(candidate, chain.last)

				if temp
					chain.concat(temp)
				else
					candidate = get_candidate
					clamp = Random.rand(candidate.length) - 1
					chain.concat(candidate[0..clamp])
				end
				links -= 1
			end
		end

		$log.info("Chain built, returning #{chain.join(" ")}")
		chain.join(" ").gsub($bot.nick, "")
	end

	# A string from somewhere in the middle to the end of the sentence
	def final_word
		candidate = get_candidate
		length = candidate.length
		clamp = Random.rand(length) - 1
		candidate[length - clamp..length-1]
	end

	def get_candidate
		candidate = @cache.sample.text
		candidate.split
	end

	def get_matching_candidate(candidate, last_word)
		@cache.length.times do
			if candidate.include?(last_word)
				clamp = Random.rand(candidate.length) -1
				return candidate[candidate.index(last_word)+1..clamp]
			end
			candidate = get_candidate
		end
		nil
	end

	def create_seed
		if @cache.last.text.include?($bot.nick)
			$log.info("Returning last word")
			return [@cache.last.text.split.last]
		end
		[@cache.sample.text.split.last]
	end
end
