require_relative 'trigger'

class Markov < ResponseTrigger

	attr_accessor :dictionary

	def initialize(trigger, random)
		@random = random
		@@dictionary = Hash.new([])
		super(trigger, random)
	end

	def proc_response
		Proc.new { new_markov(seed) }
	end

	def self.analyze(string)
		input_array = string.downcase().split()

		input_array.each_with_index do |word, idx|
			next_word = input_array[idx+1]
			unless next_word.nil? || @@dictionary[word].include?(next_word)
				@@dictionary[word] << next_word
			end
		end

	end

	def markov_response()
		if @random
			new_markov!
		else
			new_markov!($bot.msg_cache.last.text.split.last)
		end
	end

	private

	def markov_response!(seed = nil)
	   length = Random.rand(3..8)
		 chain = (seed.nil? ? [@@dictionary.keys.sample] : [seed.downcase])
		 $log.info("Starting markov chain with #{chain}")

	    while chain.length < length do
					$log.info("Chain is #{chain} and length is #{length}")
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
