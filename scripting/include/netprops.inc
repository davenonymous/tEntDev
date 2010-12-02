#if defined _netprops_included_
	#endinput
#endif
#define _netprops_included_

enum SendPropType {
	DPT_Int=0,
	DPT_Float,
	DPT_Vector,
	DPT_VectorXY,
	DPT_String,
	DPT_Array,	// An array of the base types (can't be of datatables).
	DPT_DataTable,
	DPT_NUMSendPropTypes
};

native Handle:GetSendTableByNetclass(const String:netclass[]);

native GetNumProps(Handle:hSendTable);
native Handle:GetProp(Handle:hSendTable, iIndex);
native GetTableName(Handle:hSendTable, String:sName[], size);
native GetPropName(Handle:hProp, String:sName[], size);
native Handle:GetDataTable(Handle:hProp);
native SendPropType:GetType(Handle:hProp);
native GetTypeString(Handle:hProp, String:sType[], size);
native GetBits(Handle:hProp);
native GetOffset(Handle:hProp);



/**
 * Do not edit below this line!
 */
public Extension:__ext_netprops =
{
	name = "Netprops",
	file = "netprops.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};