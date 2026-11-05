/**
 *           __             __
 *          |  \           |  |
 *      ____| $$  ______  _| $$_     ______
 *     /      $$ |      \|   $$ \   |      |
 *    |  $$$$$$$  \$$$$$$\\$$$$$$    \$$$$$$|
 *    | $$  | $$ /      $$ | $$ __  /      $$
 *    | $$__| $$|  $$$$$$$ | $$|  \|  $$$$$$$
 *     \$$    $$ \$$    $$  \$$  $$ \$$    $$
 *      \$$$$$$$  \$$$$$$$   \$$$$   \$$$$$$$
 *
 */
#define STATS_KEY_LEN (24)
#define STATS_VALUE_LEN (48)
#define STATS_LINE_LEN (256)
#define STATS_LEVEL_COST (25000)
#define STATS_LEVEL_EXP (4)

#define STATS_LINE_1 "Level:[{Level}] Sex:[{Sex}] Age:[{Age}] Origin:[{Origin}] SpawnHealth:[{SpawnHealth|50.0}] Cash:[${Cash}] Bank:[${Bank|0}] Ph:[{Phone|0}]"
#define STATS_LINE_2 "DonateRank:[{DonateRank}] MarriedTo:[{MarriedTo|No-one}] PlayingHours:[{PlayingHours|0}] LottoNr:[{LottoNr|0}] Job:[{Job|None}]"
#define STATS_LINE_3 "FishesCaught:[{FishesCaught|0}] BiggestFish:[{BiggestFish|0}] CrimesCommitted:[{Crimes|0}] TimesArrested:[{Arrests|0}] WantedDeaths:[{WantedDeaths|0}]"
#define STATS_LINE_4 "Kills:[{Kills}] Deaths:[{Deaths}] NextLevel:[${NextLevel}] Respect:[{Respect}/{RespectNeeded}] WantedLevel:[{WantedLevel|0}] Family:[{Family|None}]"
#define STATS_LINE_5 "Drugs:[{Drugs|0}] Materials:[{Materials|0}] Team:[{Team}] Disease:[{Disease|None}] Organisation:[{Organisation|None}] Rank:[{Rank|None}]"
#define STATS_LINE_ADMIN "House key [{HouseKey|255}] Business key [{BusinessKey|255}] HireKey [{HireKey|299}] int:[{Interior}] local[{Local}]"

static Map:s_Stats;

forward Stats_OnBuild(playerid,targetid);

/**
 *      ______                                   __      __
 *     /      \                                 |  \    |  |
 *    |  $$$$$$\ __    __  _______    _______  _| $$_    \$$  ______   _______    _______
 *    | $$_  \$$|  \  |  \|       \  /       \|   $$ \  |  \ /      \ |       \  /       |
 *    | $$ \    | $$  | $$| $$$$$$$\|  $$$$$$$ \$$$$$$  | $$|  $$$$$$\| $$$$$$$\|  $$$$$$$
 *    | $$$$    | $$  | $$| $$  | $$| $$        | $$ __ | $$| $$  | $$| $$  | $$ \$$    |
 *    | $$      | $$__/ $$| $$  | $$| $$_____   | $$|  \| $$| $$__/ $$| $$  | $$ _\$$$$$$|
 *    | $$       \$$    $$| $$  | $$ \$$     \   \$$  $$| $$ \$$    $$| $$  | $$|       $$
 *     \$$        \$$$$$$  \$$   \$$  \$$$$$$$    \$$$$  \$$  \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
static Stats_Key(const key[],dest[STATS_KEY_LEN])
{
    strcopy(dest,key,STATS_KEY_LEN);

    for (new i = 0;dest[i] != EOS;i++)
    {
        dest[i] = tolower(dest[i]);
    }
}

stock Stats_SetText(const key[],const value[])
{
    new lowered[STATS_KEY_LEN], stored[STATS_VALUE_LEN];
    Stats_Key(key,lowered);
    strcopy(stored,value,STATS_VALUE_LEN);

    if (!map_valid(s_Stats))
    {
        s_Stats = map_new();
    }

    map_str_remove(s_Stats,lowered);
    map_str_add_str(s_Stats,lowered,stored);
    return true;
}

stock Stats_SetNumber(const key[],value)
{
    new text[STATS_VALUE_LEN];
    format(text,sizeof(text),"%d",value);
    return Stats_SetText(key,text);
}

stock Stats_SetFloat(const key[],Float:value)
{
    new text[STATS_VALUE_LEN];
    format(text,sizeof(text),"%.1f",value);
    return Stats_SetText(key,text);
}

static Stats_Lookup(const key[],dest[],size)
{
    new lowered[STATS_KEY_LEN];
    Stats_Key(key,lowered);

    if (!map_valid(s_Stats) || !map_has_str_key(s_Stats,lowered))
    {
        return false;
    }

    map_str_get_str(s_Stats,lowered,dest,size);
    return true;
}

stock Stats_Render(const template[],dest[],size = sizeof(dest))
{
    new length = 0, i = 0;
    dest[0] = EOS;

    while (template[i] != EOS && length < size - 1)
    {
        if (template[i] != '{')
        {
            dest[length++] = template[i++];
            dest[length] = EOS;
            continue;
        }

        new close = strfind(template,"}",false,i);

        if (close == -1)
        {
            dest[length++] = template[i++];
            dest[length] = EOS;
            continue;
        }

        new token[STATS_KEY_LEN + STATS_VALUE_LEN], key[STATS_KEY_LEN], fallback[STATS_VALUE_LEN], value[STATS_VALUE_LEN];
        strmid(token,template,i + 1,close,sizeof(token));
        new bar = strfind(token,"|");

        if (bar == -1)
        {
            strcopy(key,token,sizeof(key));
            fallback[0] = EOS;
        }
        else
        {
            strmid(key,token,0,bar,sizeof(key));
            strmid(fallback,token,bar + 1,strlen(token),sizeof(fallback));
        }

        if (!Stats_Lookup(key,value,sizeof(value)))
        {
            strcopy(value,fallback,sizeof(value));
        }

        for (new c = 0;value[c] != EOS && length < size - 1;c++)
        {
            dest[length++] = value[c];
        }

        dest[length] = EOS;
        i = close + 1;
    }
}

static Stats_FillAccount(targetid)
{
    if (map_valid(s_Stats))
    {
        map_clear(s_Stats);
    }

    new level = Account_GetLevel(targetid), text[STATS_VALUE_LEN];
    Stats_SetNumber("Level",level);

    switch (Account_GetSex(targetid))
    {
        case 1:
        {
            Stats_SetText("Sex","Male");
        }
        case 2:
        {
            Stats_SetText("Sex","Female");
        }
        default:
        {
            Stats_SetText("Sex","");
        }
    }

    Stats_SetNumber("Age",Account_GetAge(targetid));

    switch (Account_GetOrigin(targetid))
    {
        case 1:
        {
            Stats_SetText("Origin","USA");
        }
        case 2:
        {
            Stats_SetText("Origin","Europe");
        }
        case 3:
        {
            Stats_SetText("Origin","Asia");
        }
        default:
        {
            Stats_SetText("Origin","");
        }
    }

    Stats_SetNumber("Cash",Account_GetCash(targetid));

    new donate = Account_GetDonateRank(targetid);

    if (donate == 1)
    {
        strcopy(text,"Power User");
    }
    else if (donate >= 2)
    {
        strcopy(text,"Donater");
    }
    else
    {
        strcopy(text,"None");
    }

    Stats_SetText("DonateRank",text);
    Stats_SetNumber("Kills",Account_GetKills(targetid));
    Stats_SetNumber("Deaths",Account_GetDeaths(targetid));
    Stats_SetNumber("NextLevel",(level + 1) * STATS_LEVEL_COST);
    Stats_SetNumber("Respect",Account_GetRespect(targetid));
    Stats_SetNumber("RespectNeeded",(level + 1) * STATS_LEVEL_EXP);

    new team = Account_GetTeam(targetid);

    if (team == 3 || team == 4)
    {
        Stats_SetText("Team","Civilian");
    }
    else
    {
        Stats_SetText("Team","");
    }

    Stats_SetNumber("Interior",Account_GetInterior(targetid));
    Stats_SetNumber("Local",Account_GetLocal(targetid));
}

stock Stats_Show(playerid,targetid)
{
    if (!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid))
    {
        return;
    }

    Stats_FillAccount(targetid);
    pawn_call_public("Stats_OnBuild","dd",playerid,targetid);

    new name[MAX_PLAYER_NAME + 1], line[STATS_LINE_LEN];
    GetPlayerName(targetid,name,sizeof(name));

    SendClientMessage(playerid,COLOR_GREEN,"_______________________________________");
    format(line,sizeof(line),"*** %s ***",name);
    SendClientMessage(playerid,COLOR_WHITE,line);

    Stats_Render(STATS_LINE_1,line);
    SendClientMessage(playerid,COLOR_GRAD1,line);
    Stats_Render(STATS_LINE_2,line);
    SendClientMessage(playerid,COLOR_GRAD3,line);
    Stats_Render(STATS_LINE_3,line);
    SendClientMessage(playerid,COLOR_GRAD4,line);
    Stats_Render(STATS_LINE_4,line);
    SendClientMessage(playerid,COLOR_GRAD5,line);
    Stats_Render(STATS_LINE_5,line);
    SendClientMessage(playerid,COLOR_GRAD5,line);

    if (Account_GetAdminLevel(playerid) >= 1)
    {
        Stats_Render(STATS_LINE_ADMIN,line);
        SendClientMessage(playerid,COLOR_GRAD6,line);
    }

    SendClientMessage(playerid,COLOR_GREEN,"_______________________________________");
}

/**
 *                        __  __  __                            __
 *                       |  \|  \|  \                          |  |
 *      _______  ______  | $$| $$| $$____    ______    _______ | $$   __   _______
 *     /       \|      \ | $$| $$| $$    \  |      \  /       \| $$  /  \ /       |
 *    |  $$$$$$$ \$$$$$$\| $$| $$| $$$$$$$\  \$$$$$$\|  $$$$$$$| $$_/  $$|  $$$$$$$
 *    | $$      /      $$| $$| $$| $$  | $$ /      $$| $$      | $$   $$  \$$    |
 *    | $$_____|  $$$$$$$| $$| $$| $$__/ $$|  $$$$$$$| $$_____ | $$$$$$\  _\$$$$$$|
 *     \$$     \\$$    $$| $$| $$| $$    $$ \$$    $$ \$$     \| $$  \$$\|       $$
 *      \$$$$$$$ \$$$$$$$ \$$ \$$ \$$$$$$$   \$$$$$$$  \$$$$$$$ \$$   \$$ \$$$$$$$
 *
 */
public Stats_OnBuild(playerid,targetid)
{
    return 1;
}
