#if defined _ted_included_
	#endinput
#endif
#define _ted_included_


native TED_SetNetprop(client, const String:sNetprop[], const String:sValue[]);
native TED_SelectEntity(client, entity);
native TED_IgnoreNetprop(client, const String:sNetprop[]);
native TED_UnignoreNetprop(client, const String:sNetprop[]);
native TED_ShowNetprops(client);
native TED_WatchNetprops(client);
native TED_StopWatchNetprops(client);
native TED_SaveNetprops(client);
native TED_CompareNetprops(client);

forward TED_OnCompare(client, const String:sNetprop[], const String:sOld[], const String:sNow[], iOffset);
forward TED_OnNetpropHint(client, const String:sText[], const String:sNetprop[]);
forward TED_OnShow(client, const String:sNetprop[], const String:sValue[], iOffset);
forward TED_OnInfo(client, const String:sText[]);