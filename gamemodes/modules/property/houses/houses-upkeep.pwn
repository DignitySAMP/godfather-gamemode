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
#define HOUSE_REPOSSESS_MIN_DAY (366)
#define HOUSE_SECONDS_PER_DAY (86400)
#define HOUSE_REPOSSESS_DAYS (5)
#define HOUSE_HOME_SOUND (1058)
#define HOUSE_HOME_RADIUS (4.0)

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
stock Houses_GetToday()
{
    return gettime() / HOUSE_SECONDS_PER_DAY;
}

stock Houses_TouchOwned(playerid)
{
    new name[HOUSE_NAME_LEN], today = Houses_GetToday();
    Property_GetPlayerName(playerid,name);

    for (new house = 0,count = Houses_GetCount();house < count;house++)
    {
        if (Houses_IsOwnerName(house,name))
        {
            Houses_SetSeenDay(house,today);
        }
    }
}

static Houses_ClearOwnerKey(const owner[],house)
{
    foreach (new playerid : Player)
    {
        new name[HOUSE_NAME_LEN];
        Property_GetPlayerName(playerid,name);

        if (!strcmp(name,owner,true) && Houses_GetKey(playerid) == house)
        {
            Houses_SetKey(playerid,HOUSE_NO_KEY);
        }
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE house_keys INNER JOIN players ON players.id = house_keys.account_id SET house_keys.house_key = %d WHERE players.name = '%e' AND house_keys.house_key = %d",HOUSE_NO_KEY,owner,house));
}

stock Houses_CheckProperty(today)
{
    new repossessed = 0;

    for (new house = 0,count = Houses_GetCount();house < count;house++)
    {
        if (!Houses_IsOwned(house) || Houses_GetSeenDay(house) <= HOUSE_REPOSSESS_MIN_DAY)
        {
            continue;
        }

        if (today - Houses_GetSeenDay(house) < HOUSE_REPOSSESS_DAYS)
        {
            continue;
        }

        new owner[HOUSE_NAME_LEN];
        Houses_GetOwner(house,owner);
        Houses_Release(house);
        Houses_ClearOwnerKey(owner,house);

        new line[96];
        format(line,sizeof(line),"REAL ESTATE: A House is available at a value of $%d",Houses_GetPrice(house));
        SendClientMessageToAll(TEAM_BALLAS_COLOR,line);
        repossessed++;
    }

    return repossessed;
}

static Houses_BeginPayday(playerid)
{
    new house = Houses_GetKey(playerid);

    if (house == HOUSE_NO_KEY || Houses_IsOwner(playerid,house))
    {
        return;
    }

    if (Houses_GetRent(house) > Account_GetCash(playerid))
    {
        Houses_SetKey(playerid,HOUSE_NO_KEY);
        SendClientMessage(playerid,COLOR_WHITE,"You have been evicted.");
    }
}

static Houses_ComputePayday(playerid)
{
    new house = Houses_GetKey(playerid);

    if (house == HOUSE_NO_KEY)
    {
        return;
    }

    if (Houses_IsOwner(playerid,house))
    {
        Payday_SetUtilityHolder(playerid,true);
        Payday_SetHouseOwner(playerid,true);
        return;
    }

    new rent = Houses_GetRent(house);

    if (rent > 0 && Payday_AddCharge(playerid,PAYDAY_LABEL_RENT,rent))
    {
        Houses_AddTakings(house,rent);
    }
}

static Houses_ChooseSpawn(playerid)
{
    new house = Houses_GetKey(playerid);

    if (house == HOUSE_NO_KEY || !Houses_GetSpawnAtHome(playerid))
    {
        return;
    }

    new Float:x, Float:y, Float:z;
    Houses_GetExit(house,x,y,z);
    Spawn_SetPoint(playerid,x,y,z,0.0,Houses_GetInterior(house),SPAWN_PRIORITY_HOUSE);
}

static Houses_FinishSpawn(playerid)
{
    new house = Houses_GetKey(playerid);

    if (house == HOUSE_NO_KEY || Spawn_GetPointPriority(playerid) != SPAWN_PRIORITY_HOUSE)
    {
        return;
    }

    Account_SetInterior(playerid,Houses_GetInterior(house));
    Account_SetLocal(playerid,Houses_GetLocal(house));
    Doors_ApplyWorld(playerid,Houses_GetDoor(house));
}

static Houses_ReachHome(playerid)
{
    if (!Houses_HasHomeWaypoint(playerid))
    {
        return;
    }

    PlayerPlaySound(playerid,HOUSE_HOME_SOUND,0.0,0.0,0.0);
    DisablePlayerCheckpoint(playerid);
    Houses_SetHomeWaypoint(playerid,false);
    Property_GameText(playerid,"~w~You are~n~~y~Home",5000,1);
}

/**
 *     __                            __
 *    |  \                          |  |
 *    | $$____    ______    ______  | $$   __   _______
 *    | $$    \  /      \  /      \ | $$  /  \ /       |
 *    | $$$$$$$\|  $$$$$$\|  $$$$$$\| $$_/  $$|  $$$$$$$
 *    | $$  | $$| $$  | $$| $$  | $$| $$   $$  \$$    |
 *    | $$  | $$| $$__/ $$| $$__/ $$| $$$$$$\  _\$$$$$$|
 *    | $$  | $$ \$$    $$ \$$    $$| $$  \$$\|       $$
 *     \$$   \$$  \$$$$$$   \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
#include <pp-hooks>

hook Payday_OnBegin(playerid)
{
    Houses_BeginPayday(playerid);
}

hook Payday_OnCompute(playerid)
{
    Houses_ComputePayday(playerid);
}

hook Payday_OnFinished()
{
    Houses_CheckProperty(Houses_GetToday());
}

hook Account_OnLogin(playerid,accountid)
{
    Houses_TouchOwned(playerid);
}

hook Spawn_OnChoose(playerid)
{
    Houses_ChooseSpawn(playerid);
}

hook OnPlayerSpawn(playerid)
{
    Houses_FinishSpawn(playerid);
}

hook OnPlayerEnterCheckpoint(playerid)
{
    Houses_ReachHome(playerid);
}
