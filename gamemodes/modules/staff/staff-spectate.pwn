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
#define STAFF_TV_RANGE (12.0)
#define STAFF_SPECTATE_TEXT_MS (2500)
#define STAFF_RESPAWN_ANGLE (1.0)
#define STAFF_DONOR_RESPAWN_ANGLE (10.0)

static s_StaffSpectatorTimer;

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
stock Staff_BeginSpectate(playerid,targetid)
{
    if (!Staff_IsTarget(targetid) || !Util_IsValidPlayer(playerid))
    {
        return false;
    }

    if (Staff_GetSpectateMode(playerid) == STAFF_SPECTATE_NONE)
    {
        Staff_SaveUnspec(playerid);

        new Float:x, Float:y, Float:z, interior, local;
        Staff_GetUnspec(playerid,x,y,z,interior,local);
        Account_SetPositionOverride(playerid,x,y,z,interior,local);
        Account_SetLocal(playerid,STAFF_NO_LOCAL);
    }

    Staff_SetSpectateTarget(playerid,targetid);
    Staff_SetSpectateMode(playerid,STAFF_SPECTATE_WATCHING);
    return true;
}

stock Staff_StopSpectate(playerid,E_STAFF_SPECTATE:mode)
{
    Staff_SetWatchingTv(playerid,false);
    Staff_SetSpectateMode(playerid,mode);
}

static Staff_WatchTick(playerid)
{
    SetPlayerColor(playerid,COLOR_SPEC);
    TogglePlayerControllable(playerid,false);

    new targetid = Staff_GetSpectateTarget(playerid);

    if (!Util_IsValidPlayer(targetid))
    {
        return;
    }

    TogglePlayerSpectating(playerid,true);

    if (Account_GetAdminLevel(playerid) >= 1)
    {
        new Float:health, name[MAX_PLAYER_NAME + 1], line[STAFF_LINE_LEN];
        GetPlayerName(targetid,name,sizeof(name));
        GetPlayerHealth(targetid,health);
        format(line,sizeof(line),"~n~~n~~n~~n~~n~~n~~y~%s(ID:%d)~n~~y~health:%.1f",name,targetid,health);
        GameTextForPlayer(playerid,line,STAFF_SPECTATE_TEXT_MS,3);
    }

    if (IsPlayerInAnyVehicle(targetid))
    {
        PlayerSpectateVehicle(playerid,GetPlayerVehicleID(targetid));
    }
    else
    {
        PlayerSpectatePlayer(playerid,targetid);
    }

    SetPlayerInterior(playerid,GetPlayerInterior(targetid));
    SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(targetid));
}

static Staff_UnspecTick(playerid)
{
    new Float:x, Float:y, Float:z, interior, local;
    Staff_GetUnspec(playerid,x,y,z,interior,local);
    TogglePlayerControllable(playerid,true);
    TogglePlayerSpectating(playerid,false);
    SetPlayerInterior(playerid,interior);
    SetPlayerVirtualWorld(playerid,Staff_GetUnspecWorld(playerid));
    Account_SetInterior(playerid,interior);
    Account_SetLocal(playerid,local);
    Staff_ClearUnspecLocal(playerid);
    Account_ClearPositionOverride(playerid);
    SetSpawnInfo(playerid,Account_GetTeam(playerid),Account_GetModel(playerid),x,y,z - 1.0,STAFF_RESPAWN_ANGLE,WEAPON:0,0,WEAPON:0,0,WEAPON:0,0);
    Factions_SetTeam(playerid,Account_GetTeam(playerid));
    Factions_ApplyTeamColour(playerid);
    Medics_ClearBill(playerid);
    Staff_SetSpectateMode(playerid,STAFF_SPECTATE_NONE);

    if (Account_GetDonateRank(playerid) > 0)
    {
        new Float:donorX, Float:donorY, Float:donorZ;
        Staff_GetDonorPosition(playerid,donorX,donorY,donorZ);
        SetSpawnInfo(playerid,Account_GetTeam(playerid),Account_GetModel(playerid),donorX,donorY,donorZ,STAFF_DONOR_RESPAWN_ANGLE,WEAPON:0,0,WEAPON:0,0,WEAPON:0,0);
        SpawnPlayer(playerid);
        SetCameraBehindPlayer(playerid);
    }
    else
    {
        SpawnPlayer(playerid);
    }
}

static Staff_RestoreTick(playerid)
{
    new Float:x, Float:y, Float:z, interior, local;
    Staff_GetUnspec(playerid,x,y,z,interior,local);
    TogglePlayerControllable(playerid,true);
    SetPlayerInterior(playerid,interior);
    SetPlayerVirtualWorld(playerid,Staff_GetUnspecWorld(playerid));
    Account_SetInterior(playerid,interior);
    Account_SetLocal(playerid,local);
    SetPlayerPos(playerid,x,y,z);
    Account_ClearPositionOverride(playerid);
    Staff_SetSpectateMode(playerid,STAFF_SPECTATE_NONE);
}

stock Staff_SpectatePass(playerid)
{
    new E_STAFF_KICK_FLAG:flag = Staff_TakeKickFlag(playerid);

    if (flag == STAFF_KICK_KICK)
    {
        Staff_KickPlayer(playerid);
        return;
    }

    if (flag == STAFF_KICK_BAN)
    {
        Staff_BanPlayer(playerid);
        return;
    }

    if (Staff_GetSpectateMode(playerid) == STAFF_SPECTATE_WATCHING)
    {
        Staff_WatchTick(playerid);
    }

    if (Staff_GetSpectateMode(playerid) == STAFF_SPECTATE_UNSPEC)
    {
        Staff_UnspecTick(playerid);
    }

    if (Staff_GetSpectateMode(playerid) == STAFF_SPECTATE_RESTORE)
    {
        Staff_RestoreTick(playerid);
    }

    if (Staff_GetSpectateMode(playerid) == STAFF_SPECTATE_RELEASE)
    {
        Factions_ApplyTeamColour(playerid);
        Staff_SetSpectateMode(playerid,STAFF_SPECTATE_NONE);
    }

    if (Staff_GetSpectateMode(playerid) == STAFF_SPECTATE_PENDING)
    {
        Staff_SetSpectateMode(playerid,STAFF_SPECTATE_RESTORE);
    }
}

Timer_Declare(Staff_SpectatorTimer)
{
    foreach (new i : Player)
    {
        if (!IsPlayerNPC(i))
        {
            Staff_SpectatePass(i);
        }
    }

    return true;
}

stock Staff_SetSpectatorRunning(bool:isRunning)
{
    if (s_StaffSpectatorTimer != 0)
    {
        KillTimer(s_StaffSpectatorTimer);
        s_StaffSpectatorTimer = 0;
    }

    if (isRunning)
    {
        s_StaffSpectatorTimer = Timer_Start(Staff_SpectatorTimer,STAFF_SPECTATE_MS);
    }
}

Timer_Declare(Staff_IdleKickTimer)
{
    foreach (new i : Player)
    {
        if (!IsPlayerNPC(i) && Account_GetAdminLevel(i) < 1 && Staff_IdleSample(i))
        {
            Staff_KickPlayer(i);
        }
    }

    return true;
}

/**
 *                                   __
 *                                  |  |
 *      _______  ______ ____    ____| $$  _______
 *     /       \|      \    \  /      $$ /       |
 *    |  $$$$$$$| $$$$$$\$$$$\|  $$$$$$$|  $$$$$$$
 *    | $$      | $$ | $$ | $$| $$  | $$ \$$    |
 *    | $$_____ | $$ | $$ | $$| $$__| $$ _\$$$$$$|
 *     \$$     \| $$ | $$ | $$ \$$    $$|       $$
 *      \$$$$$$$ \$$  \$$  \$$  \$$$$$$$ \$$$$$$$
 *
 */
CMD:tv(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];
    Util_ReadToken(params,at,token);

    if (!strcmp("off",token,true,strlen(token)))
    {
        if (Staff_IsWatchingTv(playerid))
        {
            Staff_StopSpectate(playerid,STAFF_SPECTATE_UNSPEC);
            GameTextForPlayer(playerid,"~w~                TV~n~~r~                Off",5000,6);
            PlayerPlaySound(playerid,STAFF_UNSPEC_SOUND,0.0,0.0,0.0);
        }
        else
        {
            SendClientMessage(playerid,COLOR_GREY,"   You are not watching TV !");
        }

        return 1;
    }

    new level = Account_GetAdminLevel(playerid), house = Houses_GetKey(playerid);

    if (level < 1 && Account_GetLocal(playerid) == STAFF_NO_LOCAL)
    {
        GameTextForPlayer(playerid,"~r~There is no tv here",5000,1);
        return 1;
    }

    if (level <= 1 && !Houses_IsNearExit(playerid,house,STAFF_TV_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREEN,"   You are not in your House !");
        return 1;
    }

    if (Houses_IsValid(house) && !Houses_HasTv(house))
    {
        GameTextForPlayer(playerid,"~r~This upgrade isn't installed",5000,1);
        return 1;
    }

    new targetid = Staff_FindPlayer(token);

    if (!Staff_IsTarget(targetid))
    {
        SendClientMessage(playerid,COLOR_GREEN,"Target is not available.");
        return 1;
    }

    if (Account_GetDonateRank(playerid) > 0 && !Staff_IsWatchingTv(playerid))
    {
        Staff_SaveDonorPosition(playerid);
    }

    Staff_BeginSpectate(playerid,targetid);

    new Float:health, name[MAX_PLAYER_NAME + 1], line[STAFF_LINE_LEN];
    GetPlayerHealth(targetid,health);
    GetPlayerName(targetid,name,sizeof(name));

    if (level >= 1)
    {
        format(line,sizeof(line),"Recon: (%d) %s $%d H:%.0f",targetid,name,Account_GetCash(targetid),health);
    }
    else
    {
        format(line,sizeof(line),"UAV: (%d) %s",targetid,name);
    }

    SendClientMessage(playerid,COLOR_GREEN,line);
    Staff_SetWatchingTv(playerid,true);
    return 1;
}

ALT:recon=CMD:tv;
