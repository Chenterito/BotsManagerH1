# BotsManagerH1
Script to manage bots on the server, through dvars in the CFG file you establish how many bots you want to add to the server in each game, additionally it has a manager that monitors that the teams are always balanced as long as there are bots in the game, changing the bot team to balance them.

# How to implement.

Copy the script ""MonitorBotsH1" into "h1-mod\scripts" of your server folder.

Set that dvars in your server configuration file with the values you want.

set bots_manage_add 8 // Number of bots at game start

set bots_manage_fill 10 // Number of players and bots that the script will monitor. As there are players, bots will be expelled.
