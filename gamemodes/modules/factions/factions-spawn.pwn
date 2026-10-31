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
#define FACTION_SPAWN_ANGLE (1.0)
#define FACTION_SPAWN_ROAD_ANGLE (270.0)
#define FACTION_MAYOR_LOCAL (241)
#define FACTION_MAYOR_INTERIOR (3)
#define FACTION_SCHOOL_DRIVING (0)
#define FACTION_SCHOOL_FLYING (1)
#define FACTION_SCHOOL_DRIVING_INTERIOR (3)
#define FACTION_FORCE_MESSAGE "You are part of a Family/Force, you've been forced to the right Class + Char !"

static const Float:s_FactionCopSpawns[2][3] =
{
    {1530.8369, -1664.8872, 6.2188},
    {1530.6913, -1669.4760, 6.2188}
};

static const Float:s_FactionMedicSpawns[2][3] =
{
    {1178.1, -1321.0, 14.1},
    {1177.7, -1325.0, 14.0}
};

static const s_FactionCivilianSkins[7] =
{
    7, 19, 20, 23, 73, 101, 122
};

static const s_FactionMemberTeams[FACTION_COUNT] =
{
    0, 2, 2, 2, 1, 5, 5, 0, 10, 12, 12, 12
};

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
stock Factions_RandomCivilianSkin()
{
    return s_FactionCivilianSkins[random(sizeof(s_FactionCivilianSkins))];
}

static Factions_SyncTeam(playerid)
{
    new team = Account_GetTeam(playerid);

    if (team == TEAM_ORANGE)
    {
        team = TEAM_GREEN;
    }

    Factions_SetTeam(playerid,team);
}

static Factions_Demote(playerid,const text[])
{
    Factions_OnTeamChangedNotify(playerid);
    SendClientMessage(playerid,COLOR_LIGHTRED,text);
    Factions_SetAccountTeam(playerid,TEAM_GREEN);
    Account_SetModel(playerid,Factions_RandomCivilianSkin());
    Spawn_Begin(playerid);
}

static Factions_ForceClass(playerid)
{
    SendClientMessage(playerid,COLOR_LIGHTRED,FACTION_FORCE_MESSAGE);
    Factions_OnTeamChangedNotify(playerid);

    new member = Factions_GetMember(playerid), leader = Factions_GetLeader(playerid), team = 0;

    if (member >= 1 && member < FACTION_COUNT && s_FactionMemberTeams[member] != 0)
    {
        team = s_FactionMemberTeams[member];
    }
    else if (leader >= 1 && leader <= FACTION_SCHOOL)
    {
        team = TEAM_ADMIN;
    }

    if (team == 0)
    {
        return;
    }

    Account_SetModel(playerid,Account_GetChar(playerid));
    Factions_SetAccountTeam(playerid,team);
    Spawn_Begin(playerid);
}

static Factions_EnforceClass(playerid)
{
    new member = Factions_GetMember(playerid), leader = Factions_GetLeader(playerid);

    if (Factions_GetTeam(playerid) == TEAM_ADMIN && leader < 1)
    {
        Factions_Demote(playerid,"You are not an Approved Leader, you are now a Civilian !");
    }

    if (Factions_GetTeam(playerid) == TEAM_COR && member < 1)
    {
        Factions_Demote(playerid,"You are not a Family Member, you are now a Civilian !");
    }

    if (Factions_GetTeam(playerid) == TEAM_HIT && member != FACTION_HITMAN)
    {
        Factions_Demote(playerid,"You are not a Member of this Agency, you are now a Civilian !");
    }

    if (Factions_GetTeam(playerid) == TEAM_BLUE && member > FACTION_NATIONAL_GUARD)
    {
        Factions_Demote(playerid,"You haven't applied for being an Officer / FBI / National Guard, you are now a Civilian !");
    }

    if (Factions_GetTeam(playerid) == TEAM_GREEN && (member > 0 || leader > 0))
    {
        Factions_ForceClass(playerid);
    }
}

static Factions_ChooseSpawn(playerid)
{
    if (Factions_GetLeader(playerid) == FACTION_MAYOR)
    {
        Spawn_SetPoint(playerid,356.2998,151.9914,1025.7891,FACTION_SPAWN_ANGLE,FACTION_MAYOR_INTERIOR,SPAWN_PRIORITY_MAYOR);
    }

    if (Factions_IsIn(playerid,FACTION_POLICE) || Factions_IsIn(playerid,FACTION_FBI))
    {
        new pick = random(sizeof(s_FactionCopSpawns));
        Spawn_SetPoint(playerid,s_FactionCopSpawns[pick][0],s_FactionCopSpawns[pick][1],s_FactionCopSpawns[pick][2],FACTION_SPAWN_ROAD_ANGLE,0,SPAWN_PRIORITY_POLICE);
    }

    if (Factions_IsIn(playerid,FACTION_NATIONAL_GUARD))
    {
        Spawn_SetPoint(playerid,-1346.2050,492.3983,11.2027,FACTION_SPAWN_ANGLE,0,SPAWN_PRIORITY_NATIONAL_GUARD);
    }

    if (Factions_IsIn(playerid,FACTION_MEDICS))
    {
        Spawn_SetPoint(playerid,-2656.0393,635.0596,14.4531,FACTION_SPAWN_ANGLE,0,SPAWN_PRIORITY_FIREMEN);
    }

    if (Factions_IsIn(playerid,FACTION_LCN))
    {
        Spawn_SetPoint(playerid,1124.2415,-2037.1274,69.8847,FACTION_SPAWN_ANGLE,0,SPAWN_PRIORITY_LCN);
    }

    if (Factions_IsIn(playerid,FACTION_YAKUZA))
    {
        Spawn_SetPoint(playerid,-2192.3020,646.8816,49.4375,FACTION_SPAWN_ANGLE,0,SPAWN_PRIORITY_YAKUZA);
    }

    if (Factions_IsIn(playerid,FACTION_HITMAN))
    {
        Spawn_SetPoint(playerid,1102.7017,-299.0774,73.9922,FACTION_SPAWN_ANGLE,0,SPAWN_PRIORITY_HITMAN);
    }

    if (Factions_IsIn(playerid,FACTION_NEWS))
    {
        Spawn_SetPoint(playerid,-2050.8962,460.0262,35.1719,FACTION_SPAWN_ANGLE,0,SPAWN_PRIORITY_NEWS);
    }

    if (Factions_IsIn(playerid,FACTION_TAXI))
    {
        Spawn_SetPoint(playerid,-1978.5934,102.9237,27.6875,FACTION_SPAWN_ANGLE,0,SPAWN_PRIORITY_TAXI);
    }

    if (Factions_IsInstructor(playerid))
    {
        if (Factions_GetSchoolSpawn(playerid) == FACTION_SCHOOL_DRIVING)
        {
            Spawn_SetPoint(playerid,-2032.6810,-117.4816,1035.1719,275.1114,FACTION_SCHOOL_DRIVING_INTERIOR,SPAWN_PRIORITY_INSTRUCTOR);
        }
        else if (Factions_GetSchoolSpawn(playerid) == FACTION_SCHOOL_FLYING)
        {
            Spawn_SetPoint(playerid,414.4144,2531.9580,19.1565,4.6505,0,SPAWN_PRIORITY_INSTRUCTOR);
        }
    }

    if (Factions_GetTeam(playerid) == TEAM_CYAN)
    {
        new pick = random(sizeof(s_FactionMedicSpawns));
        Spawn_SetPoint(playerid,s_FactionMedicSpawns[pick][0],s_FactionMedicSpawns[pick][1],s_FactionMedicSpawns[pick][2],FACTION_SPAWN_ROAD_ANGLE,0,SPAWN_PRIORITY_MEDIC_TEAM);
    }
}

static bool:Factions_OwnsPriority(priority)
{
    switch (priority)
    {
        case SPAWN_PRIORITY_MAYOR, SPAWN_PRIORITY_POLICE, SPAWN_PRIORITY_NATIONAL_GUARD, SPAWN_PRIORITY_FIREMEN, SPAWN_PRIORITY_LCN, SPAWN_PRIORITY_YAKUZA, SPAWN_PRIORITY_HITMAN, SPAWN_PRIORITY_NEWS, SPAWN_PRIORITY_TAXI, SPAWN_PRIORITY_INSTRUCTOR, SPAWN_PRIORITY_MEDIC_TEAM:
        {
            return true;
        }
    }

    return false;
}

static Factions_FinishSpawn(playerid)
{
    new priority = Spawn_GetPointPriority(playerid);

    if (Factions_OwnsPriority(priority))
    {
        new Float:x, Float:y, Float:z, Float:angle, interior;
        Spawn_GetPoint(playerid,x,y,z,angle,interior);
        Account_SetInterior(playerid,interior);

        if (priority == SPAWN_PRIORITY_MAYOR)
        {
            Account_SetLocal(playerid,FACTION_MAYOR_LOCAL);
        }
    }

    Factions_ApplyTeamColour(playerid);
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

hook Spawn_OnChoose(playerid)
{
    Factions_ChooseSpawn(playerid);
}

hook OnPlayerSpawn(playerid)
{
    if (IsPlayerNPC(playerid) || !Player_IsReady(playerid))
    {
        return;
    }

    Factions_SyncTeam(playerid);
    Factions_EnforceClass(playerid);
    Factions_FinishSpawn(playerid);
}
