require_relative 'trigger'

class Markov < ResponseTrigger

	attr_accessor :dictionary

	def initialize(trigger, random = false)
		@random = random
		@@dictionary = {}
		@random ? super(trigger, false) : super(trigger, true)
	end

	def proc_response
		Proc.new { markov_response() }
	end

	def self.analyze(string)
		input_array = string.split()

		input_array.each_with_index do |word, idx|
			next_word = input_array[idx+1]
			next if next_word.nil?
			if @@dictionary[word].nil?
			    @@dictionary[word] = [next_word]
			else
				@@dictionary[word] << next_word
			end
		end

	end

	def markov_response()
		if @random
			build_response()
		else
			build_response($bot.msg_cache.last.text.split.sample)
		end
	end

	private

	def build_response(seed = nil)
	   length = Random.rand(3..8)
		 chain = (seed.nil? ? [@@dictionary.keys.sample] : [seed.downcase])
		 $log.info("Starting markov chain with #{chain}")

	    while chain.length < length do
					$log.info("Chain is #{chain}")
	        if @@dictionary[chain.last].nil?
						$log.info("Sampling random word for markov chain (no non-nil candidate key found)")
	            chain << @@dictionary.keys.sample
	        else
	            chain << @@dictionary[chain.last].sample
	        end
	    end

			$log.info("Returning markov chain #{chain.join(" ")}")
			chain.join(" ")
	end

end
