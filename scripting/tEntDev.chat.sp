#pragma semicolon 1
#include <sourcemod>
#include <colors>

#define VERSION 		"0.0.1"

new Handle:g_hCvarEnabled = INVALID_HANDLE;

new bool:g_bEnabled;

public Plugin:myinfo =
{
	name 		= "tEntDev - Chat",
	author 		= "Thrawn",
	description = "Chatoutput for tEntDev",
	version 	= VERSION,
};

public OnPluginStart() {
	CreateConVar("sm_tentdev_chat_version", VERSION, "", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	g_hCvarEnabled = CreateConVar("sm_tentdev_chat_enable", "1", "Enable tEntDev chat", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	HookConVarChange(g_hCvarEnabled, Cvar_ChangedEnable);
}

public OnConfigsExecuted() {
	g_bEnabled = GetConVarBool(g_hCvarEnabled);
}

public Cvar_ChangedEnable(Handle:convar, const String:oldValue[], const String:newValue[]) {
	g_bEnabled = GetConVarBool(g_hCvarEnabled);
}

public TED_OnNetpropHint(client, const String:sText[], const String:sNetprop[]) {
	if(!g_bEnabled)return;
	if(client == 0) {
		PrintToServer("%s %s", sText, sNetprop);
	} else {
		CPrintToChat(client, "%s {olive}%s", sText, sNetprop);
	}
}

public TED_OnInfo(client, const String:sText[]) {
	if(!g_bEnabled)return;
	if(client == 0) {
		PrintToServer(sText);
	} else {
		CPrintToChat(client, "{red}%s", sText);
	}
}

public TED_OnCompare(client, const String:sNetprop[], const String:sOld[], const String:sNow[], iOffset) {
	if(!g_bEnabled)return;
	if(client == 0) {
		PrintToServer("%s (%i) changed from %s to %s", sNetprop, iOffset, sOld, sNow);
	} else {
		CPrintToChat(client, "{olive}%s {red}(%i){default} changed from {red}%s{default} to {red}%s", sNetprop, iOffset, sOld, sNow);
	}
}

public TED_OnShow(client, const String:sNetprop[], const String:sNow[], iOffset) {
	if(!g_bEnabled)return;
	if(client == 0) {
		PrintToServer("%s (%i) is %s", sNetprop, iOffset, sNow);
	} else {
		CPrintToChat(client, "{olive}%s {red}(%i){default} is {red}%s", sNetprop, iOffset, sNow);
	}
}
