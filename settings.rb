#require_relative 'BotBot'
Dir[File.join(".", "lib/*.rb")].each { |f| require f }

module Settings

	#
	#These are some default settings for BotBot. Feel free to change
	#his nickname, irc server address, etc. Port number is 6667 by default,
	#but some IRC servers may use something else. SSL is not implemented yet
	#but support is coming soon!
	#
	NICKNAME = "HirugaBotto"

	SERVER = "irc.rizon.net"

	PORT = 6667

	CHAN = "lifting"

	#
	#This is a collection of triggers that will load on startup.
	#You can remove or add any that you wish. They will be loaded
	#each time the script is run. It is generally a good idea to keep
	#most of these unless you find its behavior uneeded or irritating.
	#
	DEFAULT_TRIGGERS = {
		markov: Markov.new(NICKNAME, Proc.new{Markov.markov_response}),
		hi: ResponseTrigger.new("hi", Proc.new{"Hello #{$bot.msg_cache.last.nickname}"})
	}
end