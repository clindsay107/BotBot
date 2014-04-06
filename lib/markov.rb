require_relative 'trigger'

class Markov < ResponseTrigger

	def self.markov_response
		@cache = $bot.msg_cache
		return if @cache.length <= 1
		if @cache.length < 10
			msg = @cache.sample.text
			$log.info("Cache size under 10, returning #{msg}")
			return msg
		end
		build_chain
	end


	#build a random markov chain from the cache, using 1-4 string.
	#try to find ones that match on the last work of the latest link,
	#otherwise use a random string.
	def self.build_chain
		links = Random.rand(2..5)

		chain = create_seed

		while links > 0 do
			$log.info("Link size at #{links}")
			last_word = chain.last
			candidate = get_candidate

			(@cache.length).times do 
				if candidate.include?(last_word)
					clamp = Random.rand(candidate.length) -1
					chain.concat(candidate[candidate.index(last_word)+1..clamp])
					links -= 1
					break
				end
				candidate = get_candidate
			end
			candidate = get_candidate
			clamp = Random.rand(candidate.length) -1
			chain.concat(candidate[0..clamp])
			links -= 1
		end
		$log.info("Chain built, returning #{chain.join(" ")}")
		chain.join(" ").gsub($bot.nick, "")
	end

	def self.get_candidate
		candidate = @cache.sample.text
		candidate.split
	end

	def self.create_seed
		if @cache.last.text == $bot.nick
			return chain = @cache.sample.text.split
		end
		@cache.last.text.split
	end
end