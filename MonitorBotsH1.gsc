/*
*	 Black Ops 2 - GSC Studio by iMCSx
*
*	 Creator : Kalitos
*	 Project : AutoManagerBots
*    Mode : Multiplayer
*	 Date : 2021/05/15 - 11:22:19	
*
*/	

#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\bots\_bots;


init()
{
	SetDvarIfNotInizialized("bots_manage_add", 8);
	SetDvarIfNotInizialized("bots_manage_fill", 10);
	thread monitorBots();
	thread onPlayerConnect();
	thread teamBots();
}

monitorBots()
{
	level endon("game_ended");

	level waittill("matchStartTimer");
	
	botsToAdd = getdvarint("bots_manage_add");
	botsToFill = getdvarint("bots_manage_fill");

	if(botsToAdd > 17)
		botsToAdd = 17;
	
	if (botsToAdd > 0 )
	{
		for ( i = 0; i < botsToAdd; i++ )
		{
			spawnBotswrapper(1);
			wait 0.25;	
		}
	}
	
	if(botsToFill > 0)
	{
		for(;;)
		{
			while(botCount() + playerCount() < botsToFill)
			{
				spawnBotswrapper(1);
				wait 0.5;			
			}
			wait 3;
			if( botCount() + playerCount() > botsToFill && botCount() > 0)
				kickBot();
		}
	}
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        if(isBot(player))
        {
            player botsetdifficulty("default");
            player kickLeftoverBot();
        }
		else
		{
			player waittill("spawned_player");
			kickBot();
		}
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
	level endon("game_ended");
    for(;;)
    {
        self waittill("spawned_player");		
    }
}

kickLeftoverBot()
{
    self endon("spawned_player");
    wait 10;
    kick(self getentitynumber());

}

botCount()
{
    count = 0;
	for( i = 0; i < level.players.size; i++)
	{
		if(isbot(level.players[i]))
		{
			count++;
		}			
	}
	return count;
}

playerCount()
{
    count = 0;
	for( i = 0; i < level.players.size; i++)
	{
		if(!isbot(level.players[i]))
		{
			count++;
		}			
	}
	return count;
}

kickBot()
{
	for( i = 0; i < level.players.size; i++)
	{
		if(isbot(level.players[i]))
		{
			kick(level.players[i] getentitynumber());
			break;
		}			
	}

}

spawnBotswrapper(a)
{
    spawn_bots(a, "autoassign");
}

SetDvarIfNotInizialized(dvar, value)
{
	if(!IsInizialized(dvar))
		setDvar(dvar, value);
}
IsInizialized(dvar)
{
	result = getDvarInt(dvar);
	return !isDefined(result) || result != "";
} 

teamBots_loop()
{
	toTeam = "";
	alliesbots = 0;
	alliesplayers = 0;
	axisbots = 0;
	axisplayers = 0;
	alliesbotsArray = [];
	axisbotsArray = [];
	botToChange = undefined;

	playercount = level.players.size;

	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[ i ];

		if ( !isdefined( player.pers[ "team" ] ) )
		{
			continue;
		}

		if (  isBot(player) )
		{
			if ( player.pers[ "team" ] == "allies" )
			{
				alliesbots++;
				alliesbotsArray[alliesbotsArray.size] = player;
			}
			else if ( player.pers[ "team" ] == "axis" )
			{
				axisbots++;
				axisbotsArray[axisbotsArray.size] = player;
			}
		}
		else
		{
			if ( player.pers[ "team" ] == "allies" )
			{
				alliesplayers++;
			}
			else if ( player.pers[ "team" ] == "axis" )
			{
				axisplayers++;
			}
		}
	}

	allies = alliesbots + alliesplayers;
	axis = axisbots + axisplayers;

	if ( ( axis - allies ) > 1 )
		toTeam = "allies";
	
	if ( ( allies - axis ) > 1 )
		toTeam = "axis";

	if( toTeam == "allies")
	{
		if(axisbots > 0)
		{
			for ( i = 0; i < axisbotsArray.size; i++ )
			{
				if ( !isdefined( botToChange ) )
                {
                    botToChange = axisbotsArray[i];
                    continue;
                }

                if ( axisbotsArray[i].pers["score"] < botToChange.pers["score"] )
                    botToChange = axisbotsArray[i];
			}
			
			botToChange [[ level.onteamselection ]]( "allies" );
		}
	}
	else if( toTeam == "axis")
	{
		if(alliesbots > 0)
		{
			for ( i = 0; i < alliesbotsArray.size; i++ )
			{
				if ( !isdefined( botToChange ) )
                {
                    botToChange = alliesbotsArray[i];
                    continue;
                }

                if ( alliesbotsArray[i].pers["score"] < botToChange.pers["score"] )
                    botToChange = alliesbotsArray[i];
			}

			botToChange [[ level.onteamselection ]]( "axis" );
		}
	}
}

/*
	A server thread for monitoring all bot's teams for custom server settings.
*/
teamBots()
{
	level endon("game_ended");

	wait 30; // Time to start monitor
	for ( ;; )
	{
		wait 1.5;
		teamBots_loop();
	}
}
