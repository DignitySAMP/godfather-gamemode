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
#define MEDICS_BILL (500)
#define MEDICS_BILL_HEALTH (25.0)
#define MEDICS_FULL_HEALTH (100.0)
#define MEDICS_HEAL_SOUND (1150)
#define MEDICS_HEAL_MAX_PRICE (1000)
#define MEDICS_HEAL_RANGE (30.0)
#define MEDICS_LOCAL_RESTAURANT (101)
#define MEDICS_LOCAL_ARMOURY (102)
#define MEDICS_ARMOUR_X (1527.5)
#define MEDICS_ARMOUR_Y (-12.1)
#define MEDICS_ARMOUR_Z (1002.0)
#define MEDICS_ARMOUR_INTERIOR (99)
#define MEDICS_ARMOUR_RETURN_MS (3000)
#define MEDICS_ARMOUR_VALUE (100.0)
#define MEDICS_NOT_ACTIVE_FORMAT "   %s is not an active player."

static bool:s_MedicsBillPending[MAX_PLAYERS];
static bool:s_MedicsOnDuty[MAX_PLAYERS];
static s_MedicsOnDutyCount;
static bool:s_MedicsInArmourRoom[MAX_PLAYERS];
static Float:s_MedicsReturnPos[MAX_PLAYERS][3];
static s_MedicsReturnInterior[MAX_PLAYERS];
static s_MedicsReturnLocal[MAX_PLAYERS];

forward Medics_OnHealed(playerid,targetid);
forward Medics_ArmourReturn(playerid);

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
static Medics_DropDuty(playerid)
{
    if (s_MedicsOnDuty[playerid])
    {
        s_MedicsOnDuty[playerid] = false;
        s_MedicsOnDutyCount--;
    }
}

static Medics_Reset(playerid)
{
    Medics_DropDuty(playerid);
    s_MedicsBillPending[playerid] = false;
    s_MedicsOnDuty[playerid] = false;
    s_MedicsInArmourRoom[playerid] = false;
}

stock bool:Medics_HasBill(playerid)
{
    return Util_IsValidPlayer(playerid) && s_MedicsBillPending[playerid];
}

stock Medics_SetBill(playerid,bool:isPending)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_MedicsBillPending[playerid] = isPending;
    }
}

stock Medics_ClearBill(playerid)
{
    Medics_SetBill(playerid,false);
}

stock Medics_GetOnDutyCount()
{
    return s_MedicsOnDutyCount;
}

stock bool:Medics_ChargeBill(playerid)
{
    if (!Medics_HasBill(playerid))
    {
        return false;
    }

    if (Factions_CheckPredicate(FACTION_PREDICATE_IS_JAILED,playerid,false) || Factions_CheckPredicate(FACTION_PREDICATE_IS_PAINTBALLING,playerid,false))
    {
        return false;
    }

    s_MedicsBillPending[playerid] = false;
    Account_SetCash(playerid,Account_GetCash(playerid) - MEDICS_BILL);

    new line[64];
    format(line,sizeof(line),"DOC: Your Medical Bill comes to $%d, Have a nice day.",MEDICS_BILL);
    SendClientMessage(playerid,TEAM_CYAN_COLOR,line);
    Account_SetDeaths(playerid,Account_GetDeaths(playerid) + 1);
    SetPlayerHealth(playerid,MEDICS_BILL_HEALTH);
    return true;
}

static Medics_ToggleDuty(playerid)
{
    if (s_MedicsOnDuty[playerid])
    {
        SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You are now Off Duty from your Medic Job and will not receive calls anymore.");
        s_MedicsOnDuty[playerid] = false;
        s_MedicsOnDutyCount--;
    }
    else
    {
        SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You are now On Duty with your Medic Job and will receive calls from people in need.");
        s_MedicsOnDuty[playerid] = true;
        s_MedicsOnDutyCount++;
    }
}

stock Medics_BeginArmourRoom(playerid)
{
    new name[MAX_PLAYER_NAME + 1], line[64];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"* %s puts on body armour.",name);
    Chat_ProxDetector(MEDICS_HEAL_RANGE,playerid,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
    TogglePlayerControllable(playerid,false);
    GetPlayerPos(playerid,s_MedicsReturnPos[playerid][0],s_MedicsReturnPos[playerid][1],s_MedicsReturnPos[playerid][2]);
    s_MedicsReturnInterior[playerid] = Account_GetInterior(playerid);
    s_MedicsReturnLocal[playerid] = Account_GetLocal(playerid);
    SetPlayerPos(playerid,MEDICS_ARMOUR_X,MEDICS_ARMOUR_Y,MEDICS_ARMOUR_Z);
    Account_SetLocal(playerid,DOOR_LOCAL_OUTSIDE);
    SetPlayerInterior(playerid,MEDICS_ARMOUR_INTERIOR);
    SetPlayerArmour(playerid,MEDICS_ARMOUR_VALUE);
    s_MedicsInArmourRoom[playerid] = true;
    SetTimerEx("Medics_ArmourReturn",MEDICS_ARMOUR_RETURN_MS,false,"d",playerid);
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
public Medics_ArmourReturn(playerid)
{
    if (!Util_IsValidPlayer(playerid) || !s_MedicsInArmourRoom[playerid])
    {
        return 1;
    }

    s_MedicsInArmourRoom[playerid] = false;
    TogglePlayerControllable(playerid,true);
    SetPlayerInterior(playerid,s_MedicsReturnInterior[playerid]);
    Account_SetInterior(playerid,s_MedicsReturnInterior[playerid]);
    Account_SetLocal(playerid,s_MedicsReturnLocal[playerid]);
    SetPlayerPos(playerid,s_MedicsReturnPos[playerid][0],s_MedicsReturnPos[playerid][1],s_MedicsReturnPos[playerid][2]);
    return 1;
}

public Medics_OnHealed(playerid,targetid)
{
    return 1;
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

hook OnPlayerConnect(playerid)
{
    Medics_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Medics_Reset(playerid);
}

hook Account_OnLogout(playerid,accountid)
{
    Medics_Reset(playerid);
}

hook OnPlayerDeath(playerid,killerid,WEAPON:reason)
{
    if (!IsPlayerNPC(playerid) && Player_IsReady(playerid))
    {
        Medics_SetBill(playerid,true);
    }
}

hook OnPlayerSpawn(playerid)
{
    if (!IsPlayerNPC(playerid) && Player_IsReady(playerid))
    {
        Medics_ChargeBill(playerid);
    }
}

hook Factions_OnTeamChanged(playerid)
{
    Medics_ClearBill(playerid);

    if (!Factions_IsIn(playerid,FACTION_MEDICS))
    {
        Medics_DropDuty(playerid);
    }
}

hook Factions_OnDuty(playerid)
{
    if (Factions_IsIn(playerid,FACTION_MEDICS))
    {
        Factions_SetDutyHandled(playerid);
        Medics_ToggleDuty(playerid);
    }
}

hook Tutorial_OnFinished(playerid)
{
    Medics_ClearBill(playerid);
}
