#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <cstrike>
#include <clientprefs>
#include <lvl_ranks>

#define PLUGIN_NAME "Levels Ranks"
#define PLUGIN_AUTHOR "RoadSide Romeo"

int		g_iChooseOff[MAXPLAYERS+1];
Handle	g_hTagRank = null;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

public Plugin myinfo = {name = "[LR] Module - Tag", author = PLUGIN_AUTHOR, version = PLUGIN_VERSION}
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch(GetEngineVersion())
	{
		case Engine_CSGO, Engine_CSS: LogMessage("[%s Tag] Запущен успешно", PLUGIN_NAME);
		default: SetFailState("[%s Tag] Плагин работает только на CS:GO и CS:S", PLUGIN_NAME);
	}
}

public void OnPluginStart()
{
	LR_ModuleCount();
	HookEvent("player_spawn", PlayerSpawn);
	g_hTagRank = RegClientCookie("LR_TagRank", "LR_TagRank", CookieAccess_Private);
	LoadTranslations("levels_ranks_tag.phrases");

	for(int iClient = 1; iClient <= MaxClients; iClient++)
    {
		if(IsClientInGame(iClient))
		{
			if(AreClientCookiesCached(iClient))
			{
				OnClientCookiesCached(iClient);
			}
		}
	}
}

public void PlayerSpawn(Handle event, char[] name, bool dontBroadcast)
{	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidClient(iClient) && !g_iChooseOff[iClient])
	{
		char sText[16];
		FormatEx(sText, sizeof(sText), "[Rank %i]", LR_GetClientRank(iClient));
		CS_SetClientClanTag(iClient, sText);
	}
}

public void LR_OnMenuCreated(int iClient, int iRank, Menu& hMenu)
{
	if(iRank == 0)
	{
		char sText[64];
		SetGlobalTransTarget(iClient);
		switch(g_iChooseOff[iClient])
		{
			case 0: FormatEx(sText, sizeof(sText), "%t", "TagRankOn");
			case 1: FormatEx(sText, sizeof(sText), "%t", "TagRankOff");
		}
		hMenu.AddItem("RankTag", sText);
	}
}

public void LR_OnMenuItemSelected(int iClient, int iRank, const char[] sInfo)
{
	if(iRank == 0)
	{
		if(strcmp(sInfo, "RankTag") == 0)
		{
			switch(g_iChooseOff[iClient])
			{
				case 0:
				{
					g_iChooseOff[iClient] = 1;
					CS_SetClientClanTag(iClient, "");
				}

				case 1:
				{
					char sText[64];
					g_iChooseOff[iClient] = 0;
					FormatEx(sText, sizeof(sText), "[Rank %i]", LR_GetClientRank(iClient));
					CS_SetClientClanTag(iClient, sText);
				}
			}
		}
	}
}

public void OnClientCookiesCached(int iClient)
{
	char sBuffer[4];
	GetClientCookie(iClient, g_hTagRank, sBuffer, sizeof(sBuffer));
	g_iChooseOff[iClient] = StringToInt(sBuffer);
}

public void OnClientDisconnect(int iClient)
{
	if(AreClientCookiesCached(iClient))
	{
		char sBuffer[4];
		FormatEx(sBuffer, sizeof(sBuffer), "%i", g_iChooseOff[iClient]);
		SetClientCookie(iClient, g_hTagRank, sBuffer);	
	}
}

public void OnPluginEnd()
{
	for(int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if(IsClientInGame(iClient))
		{
			OnClientDisconnect(iClient);
		}
	}
}