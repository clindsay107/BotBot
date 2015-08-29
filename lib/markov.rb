require_relative 'trigger'

class Markov < ResponseTrigger

	def initialize(trigger, random)
		@random = random
		if random
			super(trigger, true) # It is an implicit !bang command
		else
			super(trigger, false)
		end

		@dictionary = {}
	end

	def proc_response
		Proc.new { markov_response() }
	end

	def analyze(string)
		input_array = string.downcase().split()

		input_array.each_with_index do |word, idx|
			next_word = input_array[idx+1]
			if @dictionary[word].nil? && !next_word.nil?
				@dictionary[word] = [next_word]
			elsif @dictionary[word].include?(next_word)
				@dictionary[word] << next_word
			end
		end
		
	end

	def markov_response
		return if $bot.msg_cache.length <= 2
		if $bot.msg_cache.length < 10
			msg = $bot.msg_cache.sample.text
			$log.info("Cache size under 10, returning #{msg}")
			return msg
		end

		if @random
			seed = [$bot.msg_cache.sample.text.split.last]
		else
			seed = [$bot.msg_cache.last.text.split.last]
		end

		build_chain(seed)
	end

	# Build a random markov chain from the cache, using 3-15 string.
	# Try to find ones that match on the last work of the latest link,
	# Otherwise use a random string.
	def build_chain(seed = nil)
		links = Random.rand(3..15)

		chain = seed

		while links > 0 do
			puts ">>> #{links} left"
			if (links == 1)
				chain.concat(final_word())
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
			end
			links -= 1
		end

		$log.info("Chain built, returning #{chain.join(" ")}")
		chain.join(" ").gsub($bot.nick, "")
	end

	# A string from somewhere in the middle to the end of the sentence
	def final_word
		candidate = get_candidate(4)
		length = candidate.length
		clamp = Random.rand(length-1)
		candidate[length - clamp..length]
	end

	# Recursively search for a candidate of matching minimum length
	def get_candidate(min_length = 1)
		candidate = $bot.msg_cache.sample.text

		if candidate.split.length < min_length
			return get_candidate(min_length)
		end
		candidate.split
	end

	def get_matching_candidate(candidate, last_word)
		$bot.msg_cache.length.times do
			if candidate.include?(last_word)
				clamp = Random.rand(candidate.length) -1
				return candidate[candidate.index(last_word)+1..clamp]
			end
			candidate = get_candidate
		end
		nil
	end

end
