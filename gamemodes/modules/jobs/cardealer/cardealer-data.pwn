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
static s_CardealerOffer[MAX_PLAYERS];
static s_CardealerPrice[MAX_PLAYERS];
static s_CardealerVehicle[MAX_PLAYERS];

static const s_CardealerCalls[5] = {1, 2, 3, 4, 4};

forward Cardealer_Accept(playerid,const params[]);
forward Cardealer_Cancel(playerid,const params[]);

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

static Cardealer_Reset(playerid)
{
    s_CardealerOffer[playerid] = OFFER_NONE;
    s_CardealerPrice[playerid] = 0;
    s_CardealerVehicle[playerid] = 0;
}

static Cardealer_AnnounceLevel(playerid,skill)
{
    new reached = Jobs_GetSkillLevelReached(skill), line[JOBS_LINE_LEN];

    if (reached == 0)
    {
        return;
    }

    format(line,sizeof(line),"* Your Car Dealer Skill is now Level %d, Players that buy Cars from you can call it more often.",reached);
    SendClientMessage(playerid,COLOR_YELLOW,line);
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
CMD:sellcar(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Jobs_Is(playerid,JOB_CARDEALER))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Car Dealer !");
        return 1;
    }

    if (!IsPlayerInAnyVehicle(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not in a Car !");
        return 1;
    }

    new targetid, priceText[16], price;

    if (sscanf(params,"u",targetid) || sscanf(params,"{u}s[16]",priceText))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /sellcar [playerid/PartOfName] [price]");
        return 1;
    }

    if (!Jobs_ReadPrice(priceText,price))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Price not below $1 or above $99999 !");
        return 1;
    }

    if (!Util_IsValidPlayer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Invalid ID/Name !");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,JOBS_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Can't sell to yourself!");
        return 1;
    }

    if (Vehicles_GetBoughtCalls(targetid) > 0)
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player has already bought a car, has to use /callcar first !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You offered %s to buy your Car for $%d .",targetName,price);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* Car Dealer %s wants to sell you his Car for $%d, (type /accept car) to buy.",name,price);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    s_CardealerOffer[targetid] = playerid;
    s_CardealerPrice[targetid] = price;
    s_CardealerVehicle[targetid] = GetPlayerVehicleID(playerid);
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
public Cardealer_Accept(playerid,const params[])
{
    new dealerid = s_CardealerOffer[playerid], price = s_CardealerPrice[playerid], vehicleid = s_CardealerVehicle[playerid];

    if (dealerid == OFFER_NONE || dealerid == OFFER_STALE)
    {
        s_CardealerOffer[playerid] = OFFER_NONE;
        SendClientMessage(playerid,COLOR_GREY,"   No-one offered to buy a Car !");
        return 1;
    }

    if (Account_GetCash(playerid) < price)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You can't afford the Car !");
        return 1;
    }

    if (GetPlayerVehicleID(dealerid) != vehicleid || vehicleid == 0)
    {
        SendClientMessage(playerid,COLOR_GREY,"   The Car Dealer is not in the offered Car !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], dealerName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(dealerid,dealerName,sizeof(dealerName));
    new skill = Progress_AddSkill(dealerid,PROGRESS_SKILL_CAR), calls = s_CardealerCalls[Jobs_GetSkillTier(skill)];
    Cardealer_AnnounceLevel(dealerid,skill);
    format(line,sizeof(line),"* You bought a Car for $%d, from Car Dealer %s. (You can use /callcar %d times)",price,dealerName,calls);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* You sold your Car to %s for $%d, the player can use /callcar %d times.",name,price,calls);
    SendClientMessage(dealerid,COLOR_LIGHTBLUE,line);
    Payday_AddPaycheck(dealerid,price);
    Account_SetCash(playerid,Account_GetCash(playerid) - price);
    RemovePlayerFromVehicle(dealerid);
    Vehicles_SetBoughtCar(playerid,vehicleid,calls);
    Cardealer_Reset(playerid);
    return 1;
}

public Cardealer_Cancel(playerid,const params[])
{
    Cardealer_Reset(playerid);
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
    Cardealer_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Offer_Sweep(s_CardealerOffer,playerid);
    Cardealer_Reset(playerid);
}
