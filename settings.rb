Dir[File.join(".", "lib/*.rb")].each { |f| require f }

module Settings

	#
	#These are some default settings for BotBot. Feel free to change
	#his nickname, irc server address, etc. Port number is 6667 by default,
	#but some IRC servers may use something else. SSL is not implemented yet
	#but support is coming soon!
	#
	NICKNAME = "HirugaBotto1"

	SERVER = "irc.rizon.net"

	PORT = 6667

	CHAN = "bbtest"

	#
	#This is the minimum amount of time that must pass before another response
	#can be triggered from BotBot. It is intended to prevent spamming and overloading.
	#It must be a positive integer representing seconds. Set to 0 for no delay.
	#
	DELAY = 2

	#
	#This is a collection of triggers that will load on startup.
	#You can remove or add any that you wish. They will be loaded
	#each time the script is run. It is generally a good idea to keep
	#most of these unless you find its behavior uneeded or irritating.
	#
	DEFAULT_TRIGGERS = {
		markov: Markov.new(NICKNAME, Proc.new{Markov.markov_response}, true),
		hi: ResponseTrigger.new("hi", Proc.new{Greeting.build_user_response($bot.msg_cache.last.nickname)}, true)
		
	}
end