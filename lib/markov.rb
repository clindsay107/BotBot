require_relative 'trigger'

class Markov < ResponseTrigger

	def self.markov_response
		cache = $bot.msg_cache
		return if cache.length <= 1
		# if cache.length < 5
		# 	msg = cache.sample.text
		# 	$log.info("Cache size under 30, returning #{msg}")
		# 	return msg
		# end
		build_chain(cache)
	end


	#build a random markov chain from the cache 
	def self.build_chain(cache)
	# 	t_cache = [
	# 	"this is a test",
	# 	"more test strings",
	# 	"whats up my dude",
	# 	"hey brother",
	# 	"hello",
	# 	"just doing the thing",
	# 	"typing on computers",
	# 	"we want them to string along",
	# 	"a very nice day today",
	# 	"yes I agree",
	# 	"solid test strings bro",
	# 	"coffee is good",
	# 	"mmmm coffee",
	# 	"its noon",
	# 	"lets watch LCS now bb"
	# ]
	# 	cache = t_cache

		clamp = Random.rand(1..3)
		max_length = Random.rand(5..15)
		if cache.last == $bot.nick
			chain = cache.sample.split
		else
			chain = cache.last.split
		end

		while chain.length < max_length do
			last_word = chain.last
			candidate = cache.sample.split

			(cache.length/2).times do 
				if candidate.include?(last_word)
					chain.concat(candidate[candidate.index(last_word)+1..-1])
					break
				end
				candidate = cache.sample.split
			end
			chain.concat(cache.sample.split)
		end
		chain.join(" ")
	end
end