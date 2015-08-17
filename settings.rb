Dir[File.join(".", "lib/*.rb")].each { |f| require f }

module Settings

	#
	# These are some default settings for BotBot. Feel free to change
	# his nickname, irc server address, etc. Port number is 6667 by default,
	# but some IRC servers may use something else. SSL is not implemented yet
	# but support is coming soon! Note: channel name does not need # prefix
	#

	NICKNAME = "HirugaBotto"
	SERVER = "irc.rizon.net"
	PORT = 6667
	CHAN = "lifting"

	#
	# This is the minimum amount of time that must pass before another response
	# can be triggered from BotBot. It is intended to prevent spamming and overloading.
	# It must be a positive integer representing seconds. Set to 0 for no delay.
	#

	DELAY = 1

	#
	# Postgres database settings go here. It is created as a singleton object
	# at runtime of the bot and is accessed by through a Database object. The schema
	# is loaded at object initialization by reading in the `shema.txt` file found in
	# /lib/db/schema.txt
	#

	DB_NAME = "botbotdb"

	#
	# This is a collection of triggers that you can dynamically add/remove
	# to BotBot via the !load|unload <trigger name> command. If they are not available
	# in this hash, they are not available for dynamic loading/unloading. They are
	# not necessary for the core functionality of BotBot and can be removed without fear
	# of consequence
	#

	TRIGGERS = {
		markov: Markov.new(NICKNAME, Proc.new{Markov.markov_response}, true),
		hi: ResponseTrigger.new("hi", Proc.new{Greeting.build_user_response($bot.msg_cache.last.nickname)}, true),
		random: ResponseTrigger.new("!random", Proc.new{Markov.random_markov}, true)
	}

	#
	# This is a collection of triggers that will load on startup.
	# You can remove or add any that you wish. They will be loaded
	# each time the script is run. It is generally a good idea to keep
	# most of these unless you find its behavior uneeded or irritating.
	#

	DEFAULT_TRIGGERS = {
		loaded_triggers: ResponseTrigger.new("!loaded", Proc.new{$bot.list_loaded_triggers}),
		load_trigger: ResponseTrigger.new("!load\\s(\\w+)", Proc.new{$bot.load_trigger($bot.last_match[1])}),
		unload_trigger: ResponseTrigger.new("!unload\\s(\\w+)", Proc.new{$bot.unload_trigger($bot.last_match[1])}),
 	 	join_chan: ResponseTrigger.new("!join\\s(\\w+)", Proc.new{$bot.join_chan($bot.last_match[1])}),
		leave_chan: ResponseTrigger.new("!leave\\s(\\w+)", Proc.new{$bot.leave_chan($bot.last_match[1])}),
	}
end
