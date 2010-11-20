#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <colors>

#define VERSION 		"0.0.1"

enum Games {
	Game_Unknown = -1,
	Game_CSS,
	Game_DODS,
	Game_L4D,
	Game_L4D2,
	Game_TF,
	Game_HL2MP,
	Game_INSMOD,  // Insurgency
	Game_FF,      // Fortress Forever
	Game_ZPS,     // Zombie Panic: Source
	Game_AOC,     // Age of Chivalry
	Game_FOF,     // Fistful of Frags
	Game_GES,     // Goldeneye: Source
	Game_DM       // Dark Messiah
};

new Handle:g_hNetPropKV = INVALID_HANDLE;
new String:g_sNetPropFile[PLATFORM_MAX_PATH];

new Handle:g_hSavedNetProps[MAXPLAYERS+1] = INVALID_HANDLE;
new g_iMarkedEntity[MAXPLAYERS+1];
new bool:g_bStopWatching[MAXPLAYERS+1];
new Games:g_xGame = Game_Unknown;

new Handle:g_hIgnoreNetProps = INVALID_HANDLE;

public Plugin:myinfo =
{
	name 		= "tEntDev",
	author 		= "Thrawn",
	description = "Allows to do stuff with the netprops of an entity",
	version 	= VERSION,
};

public OnPluginStart() {
	CreateConVar("sm_tentdev_version", VERSION, "", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	RegAdminCmd("sm_ted_select", Command_MarkEntity, ADMFLAG_ROOT);
	RegAdminCmd("sm_ted_show", Command_ShowNetprops, ADMFLAG_ROOT);
	RegAdminCmd("sm_ted_ignore", Command_IgnoreNetprop, ADMFLAG_ROOT);
	RegAdminCmd("sm_ted_watch", Command_WatchNetprops, ADMFLAG_ROOT);
	RegAdminCmd("sm_ted_stopwatch", Command_StopWatchNetprops, ADMFLAG_ROOT);
	RegAdminCmd("sm_ted_save", Command_SaveNetprops, ADMFLAG_ROOT);
	RegAdminCmd("sm_ted_compare", Command_CompareNetprops, ADMFLAG_ROOT);

	DetectGame();
	switch(g_xGame) {
		case Game_TF: g_sNetPropFile = "netprops.tf2.cfg";
		case Game_L4D: g_sNetPropFile = "netprops.l4d.cfg";
		case Game_L4D2: g_sNetPropFile = "netprops.l4d2.cfg";
		case Game_CSS: g_sNetPropFile = "netprops.css.cfg";
		case Game_DODS: g_sNetPropFile = "netprops.dods.cfg";
		case Game_HL2MP: g_sNetPropFile = "netprops.hl2mp.cfg";
		case Game_INSMOD: g_sNetPropFile = "netprops.insmod.cfg";
		case Game_FF: g_sNetPropFile = "netprops.ff.cfg";
		case Game_ZPS: g_sNetPropFile = "netprops.zps.cfg";
		case Game_AOC: g_sNetPropFile = "netprops.aoc.cfg";
		case Game_FOF: g_sNetPropFile = "netprops.fof.cfg";
		case Game_GES: g_sNetPropFile = "netprops.ges.cfg";
		case Game_DM: g_sNetPropFile = "netprops.dm.cfg";

	}

	decl String:path[256];
	BuildPath(Path_SM, path, sizeof(path), "configs/tEntDev/%s", g_sNetPropFile);

	LogMessage("Loading netprops from file: %s", path);

	if(FileExists(path)) {
		g_hNetPropKV = CreateKeyValues("NetProps");
		FileToKeyValues(g_hNetPropKV, path);
	} else {
		SetFailState("Cant find netprops data at %s", path);
	}

	g_hIgnoreNetProps = CreateTrie();
}

public Action:Command_IgnoreNetprop(client,args) {
	if(args == 1) {
		new String:sNetProp[32];
		GetCmdArg(1, sNetProp, sizeof(sNetProp));

		SetTrieValue(g_hIgnoreNetProps, sNetProp, 1, true);
		CPrintToChat(client, "Ignoring netprop: {olive}%s", sNetProp);
		return Plugin_Handled;
	} else {
		ReplyToCommand(client, "Usage: sm_ignore <netprop>");
		return Plugin_Handled;
	}
}

public Action:Command_UnIgnoreNetprop(client,args) {
	if(args == 1) {
		new String:sNetProp[32];
		GetCmdArg(1, sNetProp, sizeof(sNetProp));

		SetTrieValue(g_hIgnoreNetProps, sNetProp, 0, true);
		CPrintToChat(client, "Un-Ignoring netprop: {olive}%s", sNetProp);
		return Plugin_Handled;
	} else {
		ReplyToCommand(client, "Usage: sm_ignore <netprop>");
		return Plugin_Handled;
	}
}


public Action:Command_SaveNetprops(client,args) {
	if(g_hSavedNetProps[client] == INVALID_HANDLE) {
		g_hSavedNetProps[client] = CreateTrie();
	} else {
		ClearTrie(g_hSavedNetProps[client]);
	}

	new iEnt = g_iMarkedEntity[client];

	if(iEnt == -1) {
		CPrintToChat(client, "{red}No entity marked");
		return Plugin_Handled;
	}

	new iCount = SaveNetprops(client, iEnt);
	if(iCount == -1)return Plugin_Handled;

	CPrintToChat(client, "Saved {olive}%i{default} netprops", iCount);
	return Plugin_Handled;
}

SaveNetprops(client, iEnt) {
	if(!IsValidEdict(iEnt)) {
		CPrintToChat(client, "{red}Entity does not exists anymore");
		g_iMarkedEntity[client] = -1;
		CloseHandle(g_hSavedNetProps[client]);
		g_hSavedNetProps[client] = INVALID_HANDLE;
		return -1;
	}

	decl String:sNetclass[64];
	new iCount = 0;
	if(GetEntityNetClass(iEnt, sNetclass, sizeof(sNetclass))) {
		if(KvJumpToKey(g_hNetPropKV, sNetclass, false)) {
			if(KvGotoFirstSubKey(g_hNetPropKV, true)) {
				do {
					new String:sSection[64];
					KvGetSectionName(g_hNetPropKV, sSection, sizeof(sSection));
					new iBits = KvGetNum(g_hNetPropKV, "bits", 0);
					new iOffset = KvGetNum(g_hNetPropKV, "offset", 0);

					if(iOffset == 0)continue;

					new iByte = 1;
					if(iBits > 8)iByte = 2;
					if(iBits > 16)iByte = 4;

					new String:sType[16];
					KvGetString(g_hNetPropKV, "type", sType, sizeof(sType), "integer");

					if(iBits == 0 && StrEqual(sType, "integer"))continue;

					new String:sResult[64];
					if(StrEqual(sType, "integer")) {
						Format(sResult, sizeof(sResult), "%i", GetEntData(iEnt, iOffset, iByte));
					}

					if(StrEqual(sType, "vector")) {
						new Float:vData[3];
						GetEntDataVector(iEnt, iOffset, vData);
						Format(sResult, sizeof(sResult), "%.4f %.4f %.4f", vData[0], vData[1], vData[2]);
					}

					if(StrEqual(sType, "float")) {
						Format(sResult, sizeof(sResult), "%.4f", GetEntDataFloat(iEnt, iOffset));
					}

					SetTrieString(g_hSavedNetProps[client], sSection, sResult, true);
					iCount++;
				} while (KvGotoNextKey(g_hNetPropKV, true));
			} else {
				CPrintToChat(client, "Netclass %s has no netprops", sNetclass);
				return -1;
			}
		} else {
			CPrintToChat(client, "Could not find netprops definitions for {olive}%s", sNetclass);
			return -1;

		}
	}

	KvRewind(g_hNetPropKV);

	return iCount;
}

public Action:Command_CompareNetprops(client,args) {
	g_bStopWatching[client] = true;
	if(g_hSavedNetProps[client] == INVALID_HANDLE) {
		CPrintToChat(client, "{red}No netprops saved");
		return Plugin_Handled;
	}

	new iEnt = g_iMarkedEntity[client];

	if(iEnt == -1) {
		CPrintToChat(client, "{red}No entity marked");
		return Plugin_Handled;
	}

	new iCount = CompareNetprops(client, iEnt);
	if(iCount == -1)return Plugin_Handled;

	CPrintToChat(client, "Netprops changed: {olive}%i", iCount);
	return Plugin_Handled;
}

public Action:Command_WatchNetprops(client,args) {
	new iEnt = g_iMarkedEntity[client];

	if(iEnt == -1) {
		CPrintToChat(client, "{red}No entity marked");
		return Plugin_Handled;
	}

	if(g_hSavedNetProps[client] == INVALID_HANDLE) {
		g_hSavedNetProps[client] = CreateTrie();
		SaveNetprops(client, g_iMarkedEntity[client]);
	}

	g_bStopWatching[client] = false;
	CreateTimer(1.0, Timer_WatchEntity, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Handled;
}

public Action:Command_StopWatchNetprops(client,args) {
	g_bStopWatching[client] = true;
	return Plugin_Handled;
}

public OnPlayerDisconnect(client) {
	g_bStopWatching[client] = true;
	if(g_hSavedNetProps[client] != INVALID_HANDLE) {
		CloseHandle(g_hSavedNetProps[client]);
		g_hSavedNetProps[client] = INVALID_HANDLE;
	}

}

public Action:Timer_WatchEntity(Handle:timer, any:client) {
	if(g_bStopWatching[client])return Plugin_Stop;
	if(!IsClientInGame(client) || !IsClientConnected(client))return Plugin_Stop;

	new iCount = CompareNetprops(client, g_iMarkedEntity[client]);
	if(iCount == -1)return Plugin_Stop;

	SaveNetprops(client, g_iMarkedEntity[client]);
	return Plugin_Continue;
}

CompareNetprops(client, iEnt) {
	if(!IsValidEdict(iEnt)) {
		CPrintToChat(client, "{red}Entity does not exists anymore");
		g_iMarkedEntity[client] = -1;
		CloseHandle(g_hSavedNetProps[client]);
		g_hSavedNetProps[client] = INVALID_HANDLE;
		return -1;
	}

	decl String:sNetclass[64];
	new iCount = 0;
	if(GetEntityNetClass(iEnt, sNetclass, sizeof(sNetclass))) {
		if(KvJumpToKey(g_hNetPropKV, sNetclass, false)) {
			if(KvGotoFirstSubKey(g_hNetPropKV, true)) {
				do {
					new String:sSection[64];
					KvGetSectionName(g_hNetPropKV, sSection, sizeof(sSection));
					new iBits = KvGetNum(g_hNetPropKV, "bits", 0);
					new iOffset = KvGetNum(g_hNetPropKV, "offset", 0);
					if(iOffset == 0)continue;

					new bool:bIgnore = false;
					GetTrieValue(g_hIgnoreNetProps, sSection, bIgnore);
					if(bIgnore)continue;
					new iByte = 1;
					if(iBits > 8)iByte = 2;
					if(iBits > 16)iByte = 4;

					new String:sType[16];
					KvGetString(g_hNetPropKV, "type", sType, sizeof(sType), "integer");

					if(iBits == 0 && StrEqual(sType, "integer"))continue;

					new String:sResult[64];
					if(StrEqual(sType, "integer")) {
						Format(sResult, sizeof(sResult), "%i", GetEntData(iEnt, iOffset, iByte));
					}

					if(StrEqual(sType, "vector")) {
						new Float:vData[3];
						GetEntDataVector(iEnt, iOffset, vData);
						Format(sResult, sizeof(sResult), "%.4f %.4f %.4f", vData[0], vData[1], vData[2]);
					}

					if(StrEqual(sType, "float")) {
						Format(sResult, sizeof(sResult), "%.4f", GetEntDataFloat(iEnt, iOffset));
					}

					new String:sPrevious[64];
					GetTrieString(g_hSavedNetProps[client], sSection, sPrevious, sizeof(sPrevious));

					if(!StrEqual(sResult, sPrevious)) {
						iCount++;
						CPrintToChat(client, "{olive}%s{default} changed from {red}%s{default} to {red}%s", sSection, sPrevious, sResult);
					}
				} while (KvGotoNextKey(g_hNetPropKV, true));
			} else {
				CPrintToChat(client, "Netclass %s has no netprops", sNetclass);
				return -1;
			}
		} else {
			CPrintToChat(client, "Could not find netprops definitions for {olive}%s", sNetclass);
			return -1;

		}
	}

	KvRewind(g_hNetPropKV);
	return iCount;
}

public Action:Command_ShowNetprops(client,args) {
	new iEnt = g_iMarkedEntity[client];

	if(iEnt == -1) {
		CPrintToChat(client, "{red}No entity marked");
		return Plugin_Handled;
	}

	if(!IsValidEdict(iEnt)) {
		CPrintToChat(client, "{red}Entity does not exists anymore");
		g_iMarkedEntity[client] = -1;
		if(g_hSavedNetProps[client] != INVALID_HANDLE) {
			CloseHandle(g_hSavedNetProps[client]);
			g_hSavedNetProps[client] = INVALID_HANDLE;
		}
		return Plugin_Handled;
	}

	decl String:sNetclass[64];
	if(GetEntityNetClass(iEnt, sNetclass, sizeof(sNetclass))) {
		if(KvJumpToKey(g_hNetPropKV, sNetclass, false)) {
			if(KvGotoFirstSubKey(g_hNetPropKV, true)) {
				do {
					new String:sSection[64];
					KvGetSectionName(g_hNetPropKV, sSection, sizeof(sSection));
					new iBits = KvGetNum(g_hNetPropKV, "bits", 0);
					new iOffset = KvGetNum(g_hNetPropKV, "offset", 0);

					if(iOffset == 0)continue;

					new iByte = 1;
					if(iBits > 8)iByte = 2;
					if(iBits > 16)iByte = 4;

					new String:sType[16];
					KvGetString(g_hNetPropKV, "type", sType, sizeof(sType), "integer");

					if(iBits == 0 && StrEqual(sType, "integer"))continue;

					new String:sResult[64];
					if(StrEqual(sType, "integer")) {
						Format(sResult, sizeof(sResult), "%i", GetEntData(iEnt, iOffset, iByte));
					}

					if(StrEqual(sType, "vector")) {
						new Float:vData[3];
						GetEntDataVector(iEnt, iOffset, vData);
						Format(sResult, sizeof(sResult), "%.4f %.4f %.4f", vData[0], vData[1], vData[2]);
					}

					if(StrEqual(sType, "float")) {
						Format(sResult, sizeof(sResult), "%.4f", GetEntDataFloat(iEnt, iOffset));
					}

					CPrintToChat(client, "{olive}%s{default}: %s", sSection, sResult);
				} while (KvGotoNextKey(g_hNetPropKV, true));
			} else {
				CPrintToChat(client, "Netclass %s has no netprops", sNetclass);
				return Plugin_Handled;
			}
		} else {
			CPrintToChat(client, "Could not find netprops definitions for {olive}%s", sNetclass);
			return Plugin_Handled;

		}
	}

	KvRewind(g_hNetPropKV);

	return Plugin_Handled;
}

public Action:Command_MarkEntity(client,args) {
	g_bStopWatching[client] = true;
	new iEnt = GetClientAimTarget(client, false);

	if(iEnt > 0) {
		decl String:sNetclass[64];
		if(GetEntityNetClass(iEnt, sNetclass, sizeof(sNetclass))) {
			CPrintToChat(client, "You've marked: {olive}%s{default}(%i)", sNetclass, iEnt);
			g_iMarkedEntity[client] = iEnt;

			if(g_hSavedNetProps[client] != INVALID_HANDLE) {
				CloseHandle(g_hSavedNetProps[client]);
				g_hSavedNetProps[client] = INVALID_HANDLE;
			}
		}
	}

	return Plugin_Handled;
}







DetectGame()
{
	// Adapted from HLX:CE ingame plugin :3
	if (g_xGame == Game_Unknown)
	{
		new String: szGameDesc[64];
		GetGameDescription(szGameDesc, 64, true);

		if (GuessSDKVersion() == SOURCE_SDK_DARKMESSIAH)
		{
			g_xGame = Game_DM;
		}
		else if (StrContains(szGameDesc, "Counter-Strike", false) != -1)
		{
			g_xGame = Game_CSS;
		}
		else if (StrContains(szGameDesc, "Day of Defeat", false) != -1)
		{
			g_xGame = Game_DODS;
		}
		else if (StrContains(szGameDesc, "Half-Life 2 Deathmatch", false) != -1)
		{
			g_xGame = Game_HL2MP;
		}
		else if (StrContains(szGameDesc, "Team Fortress", false) != -1)
		{
			g_xGame = Game_TF;
		}
		else if (StrContains(szGameDesc, "L4D", false) != -1 || StrContains(szGameDesc, "Left 4 D", false) != -1)
		{
			g_xGame = (GuessSDKVersion() >= SOURCE_SDK_LEFT4DEAD) ? Game_L4D : Game_L4D2;
		}
		else if (StrContains(szGameDesc, "Insurgency", false) != -1)
		{
			g_xGame = Game_INSMOD;
		}
		else if (StrContains(szGameDesc, "Fortress Forever", false) != -1)
		{
			g_xGame = Game_FF;
		}
		else if (StrContains(szGameDesc, "ZPS", false) != -1)
		{
			g_xGame = Game_ZPS;
		}
		else if (StrContains(szGameDesc, "Age of Chivalry", false) != -1)
		{
			g_xGame = Game_AOC;
		}
		// game could not detected, try further
		if (g_xGame == Game_Unknown)
		{
			new String: szGameDir[64];
			GetGameFolderName(szGameDir, 64);

			if (StrContains(szGameDir, "cstrike", false) != -1)
			{
				g_xGame = Game_CSS;
			}
			else if (StrContains(szGameDir, "dod", false) != -1)
			{
				g_xGame = Game_DODS;
			}
			else if (StrContains(szGameDir, "hl2mp", false) != -1 || StrContains(szGameDir, "hl2ctf", false) != -1)
			{
				g_xGame = Game_HL2MP;
			}
			else if (StrContains(szGameDir, "fistful_of_frags", false) != -1)
			{
				g_xGame = Game_FOF;
			}
			else if (StrContains(szGameDir, "tf", false) != -1)
			{
				g_xGame = Game_TF;
			}
			else if (StrContains(szGameDir, "left4dead", false) != -1)
			{
				g_xGame = (GuessSDKVersion() == SOURCE_SDK_LEFT4DEAD) ? Game_L4D : Game_L4D2;
			}
			else if (StrContains(szGameDir, "insurgency", false) != -1)
			{
				g_xGame = Game_INSMOD;
			}
			else if (StrContains(szGameDir, "FortressForever", false) != -1)
			{
				g_xGame = Game_FF;
			}
			else if (StrContains(szGameDir, "zps", false) != -1)
			{
				g_xGame = Game_ZPS;
			}
			else if (StrContains(szGameDir, "ageofchivalry", false) != -1)
			{
				g_xGame = Game_AOC;
			}
			else if (StrContains(szGameDir, "gesource", false) != -1)
			{
				g_xGame = Game_GES;
			}
		}
	}
}