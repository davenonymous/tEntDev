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
native Handle:GetSendTableByEntity(iEntity);						//FIXME: this doesnt work for l4d2 atm.

native GetNumProps(Handle:hSendTable);
native Handle:GetProp(Handle:hSendTable, iIndex);
native GetTableName(Handle:hSendTable, String:sName[], size);
native GetPropName(Handle:hProp, String:sName[], size);
native Handle:GetDataTable(Handle:hProp);
native SendPropType:GetType(Handle:hProp);
native GetTypeString(Handle:hProp, String:sType[], size);
native GetBits(Handle:hProp);
native GetOffset(Handle:hProp);
//native bool:IsInsideArray(Handle:hProp);