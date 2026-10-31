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
#define FACTION_DOOR_HITMAN_HQ (242)
#define FACTION_GUARD_AIR_RANK (3)
#define FACTION_HITMAN_CHOPPER_RANK (3)
#define FACTION_CHAR_SWAT (285)
#define FACTION_CHAR_ARMY (287)
#define FACTION_STATS_LEN (48)

forward Factions_ReadMember(playerid);
forward Factions_ReadLeader(playerid);
forward Factions_HouseIsCop(playerid);
forward Factions_HitmanDoorCheck(playerid,doorid,index);

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
static Factions_GiveKit(playerid)
{
    if (Factions_CheckPredicate(FACTION_PREDICATE_IS_JAILED,playerid,false))
    {
        return;
    }

    if (Factions_GetTeam(playerid) != TEAM_BLUE && !Factions_IsCop(playerid))
    {
        return;
    }

    GivePlayerWeapon(playerid,WEAPON:41,500);

    if (Factions_IsOnDuty(playerid) || Factions_GetMember(playerid) == FACTION_FBI)
    {
        GivePlayerWeapon(playerid,WEAPON:41,500);
        GivePlayerWeapon(playerid,WEAPON:24,200);
        GivePlayerWeapon(playerid,WEAPON:3,1);

        if (Account_GetChar(playerid) == FACTION_CHAR_SWAT)
        {
            GivePlayerWeapon(playerid,WEAPON:25,100);
            GivePlayerWeapon(playerid,WEAPON:29,450);
        }
        else if (Account_GetChar(playerid) == FACTION_CHAR_ARMY)
        {
            GivePlayerWeapon(playerid,WEAPON:25,100);
            GivePlayerWeapon(playerid,WEAPON:31,500);
        }
    }

    if (Factions_IsIn(playerid,FACTION_NATIONAL_GUARD))
    {
        GivePlayerWeapon(playerid,WEAPON:24,200);
        GivePlayerWeapon(playerid,WEAPON:31,600);
        GivePlayerWeapon(playerid,WEAPON:29,600);
    }
}

static Factions_CheckGate(playerid,gate)
{
    switch (gate)
    {
        case VEHICLE_GATE_COP:
        {
            if (Factions_IsCop(playerid))
            {
                Vehicles_GateAllow(playerid);
            }
        }
        case VEHICLE_GATE_AMBULANCE:
        {
            if (Factions_IsIn(playerid,FACTION_MEDICS))
            {
                Vehicles_GateAllow(playerid);
            }
        }
        case VEHICLE_GATE_GUARDAIR:
        {
            if (!Factions_IsIn(playerid,FACTION_NATIONAL_GUARD))
            {
                return;
            }

            if (Factions_GetRank(playerid) < FACTION_GUARD_AIR_RANK)
            {
                Vehicles_GateDeny(playerid,VEHICLE_DENY_RANK);
            }
            else
            {
                Vehicles_GateAllow(playerid);
            }
        }
        case VEHICLE_GATE_FIRE:
        {
            if (Factions_IsIn(playerid,FACTION_MEDICS))
            {
                Vehicles_GateAllow(playerid);
            }
        }
        case VEHICLE_GATE_TAXI:
        {
            if (Factions_IsIn(playerid,FACTION_TAXI))
            {
                Vehicles_GateAllow(playerid);
            }
        }
        case VEHICLE_GATE_HITMAN:
        {
            if (!Factions_IsIn(playerid,FACTION_HITMAN))
            {
                return;
            }

            if (Factions_GetRank(playerid) < FACTION_HITMAN_CHOPPER_RANK)
            {
                Vehicles_GateDeny(playerid,VEHICLE_DENY_RANK);
            }
            else
            {
                Vehicles_GateAllow(playerid);
            }
        }
        case VEHICLE_GATE_NEWS:
        {
            if (Factions_IsIn(playerid,FACTION_NEWS))
            {
                Vehicles_GateAllow(playerid);
            }
        }
        case VEHICLE_GATE_SCHOOL:
        {
            if (Factions_IsInstructor(playerid))
            {
                Vehicles_GateAllow(playerid);
            }
        }
    }
}

static Factions_TeamText(targetid,dest[],size = sizeof(dest))
{
    new team = Factions_GetTeam(targetid);

    if (Factions_IsIn(targetid,FACTION_MEDICS))
    {
        strcopy(dest,"Medic",size);
    }
    else if (team == TEAM_GREEN || team == TEAM_ORANGE)
    {
        strcopy(dest,"Civilian",size);
    }
    else if (Factions_IsIn(targetid,FACTION_POLICE))
    {
        strcopy(dest,"Officer",size);
    }
    else if (Factions_IsIn(targetid,FACTION_FBI))
    {
        strcopy(dest,"FBI Agent",size);
    }
    else if (Factions_IsIn(targetid,FACTION_NATIONAL_GUARD))
    {
        strcopy(dest,"National Guard",size);
    }
    else if (Factions_IsIn(targetid,FACTION_LCN))
    {
        strcopy(dest,"LCN",size);
    }
    else if (Factions_IsIn(targetid,FACTION_YAKUZA))
    {
        strcopy(dest,"Yakuza",size);
    }
    else if (Factions_IsIn(targetid,FACTION_HITMAN))
    {
        strcopy(dest,"Hitmen",size);
    }
    else if (Factions_IsIn(targetid,FACTION_NEWS))
    {
        strcopy(dest,"News Reporter",size);
    }
    else if (Factions_IsIn(targetid,FACTION_TAXI))
    {
        strcopy(dest,"Taxi",size);
    }
    else if (Factions_IsIn(targetid,FACTION_SCHOOL))
    {
        strcopy(dest,"School Instructor",size);
    }
    else
    {
        dest[0] = EOS;
    }
}

static Factions_OrganisationText(targetid,dest[],size = sizeof(dest))
{
    if (Factions_IsIn(targetid,FACTION_MEDICS))
    {
        strcopy(dest,"Firemen/Paramedics",size);
    }
    else if (Factions_IsIn(targetid,FACTION_LCN))
    {
        strcopy(dest,"La Cosa Nostra",size);
    }
    else if (Factions_IsIn(targetid,FACTION_YAKUZA))
    {
        strcopy(dest,"Yakuza",size);
    }
    else if (Factions_IsIn(targetid,FACTION_SCHOOL))
    {
        strcopy(dest,"License Faction",size);
    }
    else
    {
        strcopy(dest,"None",size);
    }
}

static Factions_RankText(targetid,dest[],size = sizeof(dest))
{
    new rank = Factions_GetRank(targetid);

    if (Factions_GetTeam(targetid) == TEAM_COR)
    {
        Factions_GetMafiaTitle(rank,dest,size);
        return;
    }

    static const factions[] = {FACTION_POLICE, FACTION_FBI, FACTION_NATIONAL_GUARD, FACTION_HITMAN, FACTION_NEWS, FACTION_TAXI, FACTION_SCHOOL};

    for (new i = 0;i < sizeof(factions);i++)
    {
        if (Factions_IsIn(targetid,factions[i]))
        {
            Factions_GetRankTitle(factions[i],rank,dest,size);
            return;
        }
    }

    strcopy(dest,"None",size);
}

static Factions_FillStats(targetid)
{
    new text[FACTION_STATS_LEN];
    Factions_TeamText(targetid,text);
    Stats_SetText("Team",text);
    Factions_OrganisationText(targetid,text);
    Stats_SetText("Organisation",text);
    if (Factions_GetTeam(targetid) != TEAM_COR && Factions_CheckPredicate(FACTION_PREDICATE_IN_FAMILY,targetid,false))
    {
        return;
    }

    Factions_RankText(targetid,text);
    Stats_SetText("Rank",text);
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
public Factions_ReadMember(playerid)
{
    return Factions_GetMember(playerid);
}

public Factions_ReadLeader(playerid)
{
    return Factions_GetLeader(playerid);
}

public Factions_HouseIsCop(playerid)
{
    return Factions_IsCop(playerid);
}

public Factions_HitmanDoorCheck(playerid,doorid,index)
{
    #pragma unused doorid, index

    return Factions_IsIn(playerid,FACTION_HITMAN);
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

hook Weapons_OnGive(playerid)
{
    Factions_GiveKit(playerid);
}

hook Vehicles_OnGateCheck(playerid,vehicleid,gate)
{
    #pragma unused vehicleid

    Factions_CheckGate(playerid,gate);
}

hook Stats_OnBuild(playerid,targetid)
{
    #pragma unused playerid

    Factions_FillStats(targetid);
}
