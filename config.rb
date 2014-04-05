require_relative 'BotBot'
Dir[File.join(".", "lib/*.rb")].each { |f| require f }

	#
	#This is a collection of triggers that will load on startup.
	#You can remove or add any that you wish. They will be loaded
	#each time the script is run. It is generally a good idea to keep
	#most of these. 
	#
	LOAD_ON_START = {
		markov: Markov.new($bot.nick, Proc.new{Markov.markov_response}),
		hi: ResponseTrigger.new("hi", "Hello #{$bot.msg_cache.last.nickname}")
	}
