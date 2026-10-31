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
static bool:Death_IsKiller(playerid,killerid)
{
    return killerid != INVALID_PLAYER_ID && killerid != playerid && Util_IsValidPlayer(killerid) && !IsPlayerNPC(killerid);
}

static Death_CreditKill(killerid)
{
    if (GetPlayerState(killerid) == PLAYER_STATE_ONFOOT)
    {
        Account_SetKills(killerid,Account_GetKills(killerid) + 2);
    }
    else
    {
        Account_SetKills(killerid,Account_GetKills(killerid) + 1);
    }
}

static Death_DebitKill(playerid)
{
    Account_SetKills(playerid,Account_GetKills(playerid) - 1);
}

static Death_Sue(playerid,killerid)
{
    PlayerPlaySound(killerid,DEATH_SOUND_SUE,0.0,0.0,0.0);
    Account_SetCash(killerid,Account_GetCash(killerid) - DEATH_SUE_COST);
    Account_SetCash(playerid,Account_GetCash(playerid) + DEATH_SUE_COST + DEATH_SUE_HOSPITAL);
}

static Death_VictimCriminal(playerid,killerid,killerTeam)
{
    new victimTeam = Factions_GetTeam(playerid), slice = DEATH_SLICE, playerCash = Account_GetCash(playerid);

    if (Death_GetSafeTime(playerid) <= 0 && killerTeam != victimTeam)
    {
        Death_CreditKill(killerid);
        Death_DebitKill(playerid);
    }

    if (killerTeam == TEAM_CYAN || (killerTeam == victimTeam && victimTeam != TEAM_ORANGE))
    {
        slice = 0;
    }

    if (killerTeam != TEAM_ORANGE && killerTeam == victimTeam)
    {
        slice = 0;
    }

    if (playerCash > 0)
    {
        Account_SetCash(playerid,playerCash - slice);
    }
    else
    {
        slice += DEATH_SLICE_BROKE_BONUS;
    }

    Account_SetCash(killerid,Account_GetCash(killerid) + slice);
    PlayerPlaySound(killerid,DEATH_SOUND_KILL,0.0,0.0,0.0);
}

static Death_VictimCop(playerid,killerid,killerTeam)
{
    Death_DebitKill(playerid);

    if (killerTeam == TEAM_BLUE)
    {
        Death_Sue(playerid,killerid);
    }

    if (killerTeam >= DEATH_TEAM_MAFIA_MIN && Death_GetSafeTime(playerid) <= 0)
    {
        Death_CreditKill(killerid);
    }
}

static Death_VictimCivilian(playerid,killerid,killerTeam)
{
    if (killerTeam == TEAM_BLUE && Law_GetWantedLevel(playerid) < 1)
    {
        Death_Sue(playerid,killerid);
    }
}

static Death_VictimMedic(playerid,killerid,killerTeam)
{
    if (killerTeam == TEAM_BLUE || killerTeam == TEAM_CYAN)
    {
        Death_Sue(playerid,killerid);
    }
}

static Death_Settle(playerid,killerid)
{
    new victimTeam = Factions_GetTeam(playerid), killerTeam = Factions_GetTeam(killerid);

    if (victimTeam >= TEAM_ORANGE)
    {
        Death_VictimCriminal(playerid,killerid,killerTeam);
    }
    else if (victimTeam == TEAM_BLUE)
    {
        Death_VictimCop(playerid,killerid,killerTeam);
    }
    else if (victimTeam == TEAM_GREEN)
    {
        Death_VictimCivilian(playerid,killerid,killerTeam);
    }
    else if (victimTeam == TEAM_CYAN)
    {
        Death_VictimMedic(playerid,killerid,killerTeam);
    }
}

stock Death_Process(playerid,killerid,reason)
{
    new bool:hasKiller = Death_IsKiller(playerid,killerid);

    Account_SetLocal(playerid,DOOR_LOCAL_OUTSIDE);

    if (hasKiller && GetPlayerState(killerid) == PLAYER_STATE_DRIVER)
    {
        SendClientMessage(killerid,COLOR_YELLOW,"DriveBy Kill, don't abuse it, On foot gets you $$$!");
        return;
    }

    if (reason == DEATH_MINIGUN && hasKiller)
    {
        new name[MAX_PLAYER_NAME + 1], line[DEATH_LINE_LEN];
        GetPlayerName(killerid,name,sizeof(name));
        format(line,sizeof(line),"AdmWarning: [%d]%s just killed a player with minigun, be sure he's not fake-killing.",killerid,name);
        Staff_SendAdmins(COLOR_YELLOW,line,1);
    }

    if (Factions_CheckPredicate(FACTION_PREDICATE_IS_PAINTBALLING,playerid,false))
    {
        pawn_call_public("Death_OnPaintballKill","dd",playerid,hasKiller ? killerid : INVALID_PLAYER_ID);
        return;
    }

    pawn_call_public("Death_OnKilled","ddd",playerid,hasKiller ? killerid : INVALID_PLAYER_ID,reason);

    if (hasKiller)
    {
        Death_Settle(playerid,killerid);
    }

    SetPlayerColor(playerid,COLOR_GRAD2);
}
