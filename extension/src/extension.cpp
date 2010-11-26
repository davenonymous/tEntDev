/**
 * vim: set ts=4 :
 * =============================================================================
 * SourceMod Sample Extension
 * Copyright (C) 2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */

#include "extension.h"
#include "server_class.h"
/**
 * @file extension.cpp
 * @brief Implement extension code here.
 */

SendTableHandler g_SendTableHandler;
HandleType_t g_SendTableHandle=0;


cell_t GetDataTable(IPluginContext *pContext, const cell_t *params) {
	Handle_t hndl = static_cast<Handle_t>(params[1]);
	HandleError err;
	HandleSecurity sec;
	sec.pOwner = NULL;
	sec.pIdentity = myself->GetIdentity();

	SendProp *pProp;
	
	if ((err=g_pHandleSys->ReadHandle(hndl, g_SendTableHandle, &sec, (void **)&pProp)) != HandleError_None)
	{
		return pContext->ThrowNativeError("Invalid SendProp handle %x (error %d)", hndl, err);
	}
	
	return g_pHandleSys->CreateHandle(g_SendTableHandle, 
		pProp->GetDataTable(),
		pContext->GetIdentity(), 
		myself->GetIdentity(), 
		NULL);
}

cell_t IsInsideArray(IPluginContext *pContext, const cell_t *params) {
	Handle_t hndl = static_cast<Handle_t>(params[1]);
	HandleError err;
	HandleSecurity sec;
	sec.pOwner = NULL;
	sec.pIdentity = myself->GetIdentity();

	SendProp *pProp;
	
	if ((err=g_pHandleSys->ReadHandle(hndl, g_SendTableHandle, &sec, (void **)&pProp)) != HandleError_None)
	{
		return pContext->ThrowNativeError("Invalid SendProp handle %x (error %d)", hndl, err);
	}
	
	return pProp->IsInsideArray();
}

cell_t GetOffset(IPluginContext *pContext, const cell_t *params) {
	Handle_t hndl = static_cast<Handle_t>(params[1]);
	HandleError err;
	HandleSecurity sec;
	sec.pOwner = NULL;
	sec.pIdentity = myself->GetIdentity();

	SendProp *pProp;
	
	if ((err=g_pHandleSys->ReadHandle(hndl, g_SendTableHandle, &sec, (void **)&pProp)) != HandleError_None)
	{
		return pContext->ThrowNativeError("Invalid SendProp handle %x (error %d)", hndl, err);
	}
	
	return pProp->GetOffset();
}

cell_t GetBits(IPluginContext *pContext, const cell_t *params) {
	Handle_t hndl = static_cast<Handle_t>(params[1]);
	HandleError err;
	HandleSecurity sec;
	sec.pOwner = NULL;
	sec.pIdentity = myself->GetIdentity();

	SendProp *pProp;
	
	if ((err=g_pHandleSys->ReadHandle(hndl, g_SendTableHandle, &sec, (void **)&pProp)) != HandleError_None)
	{
		return pContext->ThrowNativeError("Invalid SendProp handle %x (error %d)", hndl, err);
	}
	
	return pProp->m_nBits;
}

cell_t GetType(IPluginContext *pContext, const cell_t *params) {
	Handle_t hndl = static_cast<Handle_t>(params[1]);
	HandleError err;
	HandleSecurity sec;
	sec.pOwner = NULL;
	sec.pIdentity = myself->GetIdentity();

	SendProp *pProp;
	
	if ((err=g_pHandleSys->ReadHandle(hndl, g_SendTableHandle, &sec, (void **)&pProp)) != HandleError_None)
	{
		return pContext->ThrowNativeError("Invalid SendProp handle %x (error %d)", hndl, err);
	}
	
	return pProp->GetType();
}

cell_t GetTypeString(IPluginContext *pContext, const cell_t *params) {
	Handle_t hndl = static_cast<Handle_t>(params[1]);
	HandleError err;
	HandleSecurity sec;
	sec.pOwner = NULL;
	sec.pIdentity = myself->GetIdentity();

	SendProp *pProp;
	
	if ((err=g_pHandleSys->ReadHandle(hndl, g_SendTableHandle, &sec, (void **)&pProp)) != HandleError_None)
	{
		return pContext->ThrowNativeError("Invalid SendProp handle %x (error %d)", hndl, err);
	}

	const char *sType = GetDTTypeName(pProp->GetType());

	if(sType != NULL) {
		pContext->StringToLocal(params[2], params[3], sType);
		return strlen(sType);
	}
	
	return 0;
}

cell_t GetTableName(IPluginContext *pContext, const cell_t *params) {
	Handle_t hndl = static_cast<Handle_t>(params[1]);
	HandleError err;
	HandleSecurity sec;
	sec.pOwner = NULL;
	sec.pIdentity = myself->GetIdentity();

	SendTable *pTable;

	if ((err=g_pHandleSys->ReadHandle(hndl, g_SendTableHandle, &sec, (void **)&pTable)) != HandleError_None)
	{
		return pContext->ThrowNativeError("Invalid SendTable handle %x (error %d)", hndl, err);
	}

	pContext->StringToLocal(params[2], params[3], pTable->GetName());
	return strlen(pTable->GetName());
}

cell_t GetPropName(IPluginContext *pContext, const cell_t *params) {
	Handle_t hndl = static_cast<Handle_t>(params[1]);
	HandleError err;
	HandleSecurity sec;
	sec.pOwner = NULL;
	sec.pIdentity = myself->GetIdentity();

	SendProp *pProp;
	
	if ((err=g_pHandleSys->ReadHandle(hndl, g_SendTableHandle, &sec, (void **)&pProp)) != HandleError_None)
	{
		return pContext->ThrowNativeError("Invalid SendProp handle %x (error %d)", hndl, err);
	}

	pContext->StringToLocal(params[2], params[3], pProp->GetName());
	return strlen(pProp->GetName());
}

cell_t GetProp(IPluginContext *pContext, const cell_t *params) {
	Handle_t hndl = static_cast<Handle_t>(params[1]);
	HandleError err;
	HandleSecurity sec;
	sec.pOwner = NULL;
	sec.pIdentity = myself->GetIdentity();

	SendTable *pTable;
	
	if ((err=g_pHandleSys->ReadHandle(hndl, g_SendTableHandle, &sec, (void **)&pTable)) != HandleError_None)
	{
		return pContext->ThrowNativeError("Invalid SendTable handle %x (error %d)", hndl, err);
	}

	return g_pHandleSys->CreateHandle(g_SendTableHandle, 
		pTable->GetProp(params[2]),
		pContext->GetIdentity(), 
		myself->GetIdentity(), 
		NULL);
}

cell_t GetNumProps(IPluginContext *pContext, const cell_t *params) {
	Handle_t hndl = static_cast<Handle_t>(params[1]);
	HandleError err;
	HandleSecurity sec;
	sec.pOwner = NULL;
	sec.pIdentity = myself->GetIdentity();

	SendTable *pTable;
	
	if ((err=g_pHandleSys->ReadHandle(hndl, g_SendTableHandle, &sec, (void **)&pTable)) != HandleError_None)
	{
		return pContext->ThrowNativeError("Invalid SendTable handle %x (error %d)", hndl, err);
	}

	return pTable->GetNumProps();
}

cell_t GetSendTableByEntity(IPluginContext *pContext, const cell_t *params) {
	edict_t *pEdict = engine->PEntityOfEntIndex(params[1]);
	if (!pEdict || pEdict->IsFree() || !pEdict->GetNetworkable())
	{
		return BAD_HANDLE;
	}
	
	ServerClass *sc = pEdict->GetNetworkable()->GetServerClass();
	
	if (sc == NULL)
	{
		META_CONPRINTF("Could not find server class for entity\n");
		return BAD_HANDLE;
	}

	return g_pHandleSys->CreateHandle(g_SendTableHandle, 
		sc->m_pTable, 
		pContext->GetIdentity(), 
		myself->GetIdentity(), 
		NULL);
}

cell_t GetSendTableByNetclass(IPluginContext *pContext, const cell_t *params) {
	char *title;
	pContext->LocalToString(params[1], &title);

	ServerClass *sc = UTIL_FindServerClass(title);
	if (sc == NULL)
	{
		META_CONPRINTF("Could not open find netclass \"%s\"\n", title);
		return BAD_HANDLE;
	}

	return g_pHandleSys->CreateHandle(g_SendTableHandle, 
		sc->m_pTable, 
		pContext->GetIdentity(), 
		myself->GetIdentity(), 
		NULL);
}

ServerClass *UTIL_FindServerClass(const char *classname)
{
	ServerClass *sc = gamedll->GetAllServerClasses();
	while (sc)
	{
		if (strcmp(classname, sc->GetName()) == 0)
		{
			return sc;
		}
		sc = sc->m_pNext;
	}

	return NULL;
}

const char *GetDTTypeName(int type)
{
	switch (type)
	{
	case DPT_Int:
		{
			return "integer";
		}
	case DPT_Float:
		{
			return "float";
		}
	case DPT_Vector:
		{
			return "vector";
		}
	case DPT_String:
		{
			return "string";
		}
	case DPT_Array:
		{
			return "array";
		}
	case DPT_DataTable:
		{
			return "datatable";
		}
	default:
		{
			return NULL;
		}
	}

	return NULL;
}

bool SMNetprops::SDK_OnLoad(char *error, size_t err_max, bool late)
{
	sharesys->AddNatives(myself, netprop_natives);
	g_SendTableHandle = g_pHandleSys->CreateType("NetProp", &g_SendTableHandler, 0, NULL, NULL, myself->GetIdentity(), NULL);
	
	return true;
}

void SMNetprops::SDK_OnUnload()
{
	g_pHandleSys->RemoveType(g_SendTableHandle, myself->GetIdentity());
}

void SendTableHandler::OnHandleDestroy(HandleType_t type, void *object)
{
}

const sp_nativeinfo_t netprop_natives[] = 
{		
	{"GetSendTableByNetclass",	GetSendTableByNetclass},
	{"GetSendTableByEntity",	GetSendTableByEntity},	
	{"GetNumProps",	GetNumProps},
	{"GetTableName",	GetTableName},
	{"GetPropName",	GetPropName},
	{"GetProp",	GetProp},
	{"GetDataTable", GetDataTable},
	{"GetTypeString", GetTypeString},
	{"GetType", GetType},
	{"GetOffset", GetOffset},
	{"GetBits", GetBits},	
	{"IsInsideArray", IsInsideArray},
	
	{NULL,			NULL}
};

SMNetprops g_SMNetprops;		/**< Global singleton for extension's main interface */

SMEXT_LINK(&g_SMNetprops);