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
#define MECHANIC_REPAIR_HEALTH (1000.0)

static s_MechanicRepairOffer[MAX_PLAYERS];
static s_MechanicRepairPrice[MAX_PLAYERS];
static s_MechanicRefillOffer[MAX_PLAYERS];
static s_MechanicRefillPrice[MAX_PLAYERS];
static bool:s_MechanicOnDuty[MAX_PLAYERS];
static s_MechanicOnDutyCount;

static const s_MechanicFuel[5] = {15, 40, 60, 80, 100};

forward Mechanic_AcceptRepair(playerid,const params[]);
forward Mechanic_CancelRepair(playerid,const params[]);
forward Mechanic_AcceptRefill(playerid,const params[]);
forward Mechanic_CancelRefill(playerid,const params[]);
forward Mechanic_AcceptCall(playerid,const params[]);
forward Mechanic_CancelCall(playerid,const params[]);
forward Mechanic_ServiceCall(playerid,const params[]);

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

static Mechanic_Reset(playerid)
{
    s_MechanicRepairOffer[playerid] = OFFER_NONE;
    s_MechanicRepairPrice[playerid] = 0;
    s_MechanicRefillOffer[playerid] = OFFER_NONE;
    s_MechanicRefillPrice[playerid] = 0;
    s_MechanicOnDuty[playerid] = false;
}

static Mechanic_AnnounceLevel(playerid,skill)
{
    new reached = Jobs_GetSkillLevelReached(skill), line[JOBS_LINE_LEN];

    if (reached == 0)
    {
        return;
    }

    format(line,sizeof(line),"* Your Car Mechanic Skill is now Level %d, you can add more Fuel to any Players Cars.",reached);
    SendClientMessage(playerid,COLOR_YELLOW,line);
}

static Mechanic_Offer(playerid,const params[],const usage[],const offerText[],const askText[],bool:isRefill)
{
    if (!Jobs_Is(playerid,JOB_MECHANIC))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Car Mechanic!");
        return;
    }

    new targetid, priceText[16], price;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,usage);
        return;
    }

    sscanf(params,"{u}s[16]",priceText);

    if (!Jobs_ReadPrice(priceText,price))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Price not lower than 1, or above 99999!");
        return;
    }

    if (!Util_IsValidPlayer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is offline.");
        return;
    }

    if (!Util_IsNear(playerid,targetid,JOBS_NEAR_RANGE) || !IsPlayerInAnyVehicle(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you / not in a car.");
        return;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Can't do that!");
        return;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),offerText,targetName,price);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),askText,name,price);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);

    if (isRefill)
    {
        s_MechanicRefillOffer[targetid] = playerid;
        s_MechanicRefillPrice[targetid] = price;
    }
    else
    {
        s_MechanicRepairOffer[targetid] = playerid;
        s_MechanicRepairPrice[targetid] = price;
    }
}

static Mechanic_ToggleDuty(playerid)
{
    if (s_MechanicOnDuty[playerid])
    {
        SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You are now Off Duty from your Car Mechanic Job and will not receive calls anymore.");
        s_MechanicOnDuty[playerid] = false;
        s_MechanicOnDutyCount--;
    }
    else
    {
        SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You are now On Duty with your Car Mechanic Job and will receive calls from people in need.");
        s_MechanicOnDuty[playerid] = true;
        s_MechanicOnDutyCount++;
    }
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
CMD:refill(cmdid, playerid, params[])
{
    #pragma unused cmdid

    Mechanic_Offer(playerid,params,"USAGE: /refill [playerid/PartOfName] [price]","* You offered %s to refill his car for $%d .","* Car Mechanic %s wants to refill your car for $%d, (type /accept refill) to accept.",true);
    return 1;
}

CMD:repair(cmdid, playerid, params[])
{
    #pragma unused cmdid

    Mechanic_Offer(playerid,params,"USAGE: /repair [playerid/PartOfName] [price]","* You offered %s to fix his car for $%d .","* Car Mechanic %s wants to repair your car for $%d, (type /accept repair) to accept.",false);
    return 1;
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
public Mechanic_AcceptRefill(playerid,const params[])
{
    new mechanicid = s_MechanicRefillOffer[playerid], price = s_MechanicRefillPrice[playerid];

    if (mechanicid == OFFER_NONE || mechanicid == OFFER_STALE)
    {
        s_MechanicRefillOffer[playerid] = OFFER_NONE;
        SendClientMessage(playerid,COLOR_GREY,"   No-one offered to Refill your Car !");
        return 1;
    }

    if (Account_GetCash(playerid) < price)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You can't afford the Refill !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], mechanicName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(mechanicid,mechanicName,sizeof(mechanicName));
    new skill = Progress_AddSkill(mechanicid,PROGRESS_SKILL_MECH), fuel = s_MechanicFuel[Jobs_GetSkillTier(skill)];
    Mechanic_AnnounceLevel(mechanicid,skill);
    format(line,sizeof(line),"* You refilled your car with %d%%, for $%d by Car Mechanic %s.",fuel,price,mechanicName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* You refilled %s's car with %d%%, the $%d has been added to your PayCheck.",name,fuel,price);
    SendClientMessage(mechanicid,COLOR_LIGHTBLUE,line);
    Payday_AddPaycheck(mechanicid,price);
    Account_SetCash(playerid,Account_GetCash(playerid) - price);
    Fuel_AddCapped(Vehicles_GetLastCar(playerid),fuel);
    s_MechanicRefillOffer[playerid] = OFFER_NONE;
    s_MechanicRefillPrice[playerid] = 0;
    return 1;
}

public Mechanic_CancelRefill(playerid,const params[])
{
    s_MechanicRefillOffer[playerid] = OFFER_NONE;
    s_MechanicRefillPrice[playerid] = 0;
    return 1;
}

public Mechanic_AcceptRepair(playerid,const params[])
{
    new mechanicid = s_MechanicRepairOffer[playerid], price = s_MechanicRepairPrice[playerid];

    if (mechanicid == OFFER_NONE || mechanicid == OFFER_STALE)
    {
        s_MechanicRepairOffer[playerid] = OFFER_NONE;
        SendClientMessage(playerid,COLOR_GREY,"   No-one offered you to Repair your Car !");
        return 1;
    }

    if (Account_GetCash(playerid) < price)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You can't afford the Repair !");
        return 1;
    }

    if (!IsPlayerInAnyVehicle(playerid))
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], mechanicName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(mechanicid,mechanicName,sizeof(mechanicName));
    SetVehicleHealth(GetPlayerVehicleID(playerid),MECHANIC_REPAIR_HEALTH);
    format(line,sizeof(line),"* You repaired your car for $%d by Car Mechanic %s.",price,mechanicName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* You fixed %s's car, the $%d has been added to your PayCheck.",name,price);
    SendClientMessage(mechanicid,COLOR_LIGHTBLUE,line);
    Mechanic_AnnounceLevel(mechanicid,Progress_AddSkill(mechanicid,PROGRESS_SKILL_MECH));
    Payday_AddPaycheck(mechanicid,price);
    Account_SetCash(playerid,Account_GetCash(playerid) - price);
    s_MechanicRepairOffer[playerid] = OFFER_NONE;
    s_MechanicRepairPrice[playerid] = 0;
    return 1;
}

public Mechanic_CancelRepair(playerid,const params[])
{
    s_MechanicRepairOffer[playerid] = OFFER_NONE;
    s_MechanicRepairPrice[playerid] = 0;
    return 1;
}

public Mechanic_ServiceCall(playerid,const params[])
{
    Calls_Request(playerid,CALL_MECHANIC,s_MechanicOnDutyCount);
    return 1;
}

public Mechanic_AcceptCall(playerid,const params[])
{
    if (!Jobs_Is(playerid,JOB_MECHANIC))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Car Mechanic !");
        return 1;
    }

    Calls_Accept(playerid,CALL_MECHANIC);
    return 1;
}

public Mechanic_CancelCall(playerid,const params[])
{
    return Calls_Cancel(playerid,CALL_MECHANIC);
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
    Mechanic_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    if (s_MechanicOnDuty[playerid])
    {
        s_MechanicOnDutyCount--;
    }

    Offer_Sweep(s_MechanicRepairOffer,playerid);
    Offer_Sweep(s_MechanicRefillOffer,playerid);
    Mechanic_Reset(playerid);
}

hook Factions_OnDuty(playerid)
{
    if (Jobs_Is(playerid,JOB_MECHANIC) && !Factions_IsIn(playerid,FACTION_MEDICS))
    {
        Factions_SetDutyHandled(playerid);
        Mechanic_ToggleDuty(playerid);
    }
}
