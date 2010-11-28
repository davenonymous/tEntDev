#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <tentdev>

#define VERSION 		"0.1.0"


public Plugin:myinfo =
{
	name 		= "tEntDev - Aim",
	author 		= "Thrawn",
	description = "Selects an entity by aiming at it",
	version 	= VERSION,
};

public OnPluginStart() {
	CreateConVar("sm_tentdev_aim_version", VERSION, "", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	RegAdminCmd("sm_ted_select", Command_MarkEntity, ADMFLAG_ROOT);
}

public Action:Command_MarkEntity(client,args) {
	new iEnt = GetClientAimTarget(client, false);
	TED_SelectEntity(client, iEnt);

	return Plugin_Handled;
}