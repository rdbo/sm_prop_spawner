//<< Modified by rdbo >>
//Original version made by FusionLock
//Original version URL: https://forums.alliedmods.net/showthread.php?p=2229873

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

#define NAME "Prop Spawner"
#define AUTHOR "rdbo"
#define DESCRIPTION "Allows admins to spawn props using !prop <prop_name>"
#define VERSION "1.0"
#define URL ""
#define ADMFLAG_PROP ADMFLAG_GENERIC

char g_sPropsPath[64];

public Plugin myinfo = {name = NAME, author = AUTHOR, description = DESCRIPTION, version = VERSION, url = URL};

public void OnPluginStart()
{
    RegAdminCmd("sm_prop", CMD_Prop, ADMFLAG_PROP, "Spawns a prop");
    BuildPath(Path_SM, g_sPropsPath, sizeof(g_sPropsPath), "configs/prop_database.txt");
}

public Action CMD_Prop(int client, int args)
{
    if (args != 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_prop <prop_name>");
        return Plugin_Handled;
    }
    
    char prop_name[255];
    char prop_mdl[255];
    
    GetCmdArg(1, prop_name, sizeof(prop_name));
    
    if (CheckPropDatabase(prop_name, prop_mdl, sizeof(prop_mdl)))
    {
        SpawnEntity(client, prop_mdl);
    }
    
    return Plugin_Handled;
}

//Prop Spawner Forward:
public bool FilterPlayer(int iEntity, any aContentsMask)
{
	return iEntity > MaxClients;
}

//Props Spawner Stocks:
public bool CheckPropDatabase(char[] sCommand, char[] sModel, int iMaxLengh)
{
	char sPropModel[128];

	KeyValues hProps = CreateKeyValues("Props");

	FileToKeyValues(hProps, g_sPropsPath);

	KvGetString(hProps, sCommand, sPropModel, sizeof(sPropModel), "null");

	if(StrEqual(sPropModel, "null", true))
	{
		CloseHandle(hProps);

		return false;
	}

	CloseHandle(hProps);

	strcopy(sModel, iMaxLengh, sPropModel);

	return true;
}

public void SpawnEntity(int iClient, char[] sModel)
{
	float fAngles[3], fCAngles[3], fCOrigin[3], fOrigin[3];

	GetClientAbsAngles(iClient, fAngles);

	GetClientEyePosition(iClient, fCOrigin);

	GetClientEyeAngles(iClient, fCAngles);

	Handle hTraceRay = TR_TraceRayFilterEx(fCOrigin, fCAngles, MASK_SOLID, RayType_Infinite, FilterPlayer);

	if(TR_DidHit(hTraceRay))
	{
		TR_GetEndPosition(fOrigin, hTraceRay);

		CloseHandle(hTraceRay);
	}

	int iEnt = CreateEntityByName("prop_physics_override");

	PrecacheModel(sModel);

	DispatchKeyValue(iEnt, "model", sModel);

	DispatchSpawn(iEnt);

	TeleportEntity(iEnt, fOrigin, fAngles, NULL_VECTOR);
}
