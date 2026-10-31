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
#define OFFER_NAME_LEN (16)
#define OFFER_MAX (32)
#define OFFER_REST_LEN (128)
#define OFFER_NONE (INVALID_PLAYER_ID)
#define OFFER_STALE (-2)

enum
{
    OFFER_KIND_ACCEPT = 0,
    OFFER_KIND_CANCEL,
    OFFER_KIND_SERVICE,
    OFFER_KIND_COUNT
}

static s_OfferNames[OFFER_KIND_COUNT][OFFER_MAX][OFFER_NAME_LEN];
static s_OfferCallbacks[OFFER_KIND_COUNT][OFFER_MAX][JOBS_CALLBACK_LEN];
static s_OfferCounts[OFFER_KIND_COUNT];

forward Jobs_AcceptTicket(playerid,const params[]);
forward Jobs_CancelTicket(playerid,const params[]);

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
static bool:Offer_Register(kind,const name[],const callback[])
{
    if (kind < 0 || kind >= OFFER_KIND_COUNT || name[0] == EOS || strlen(name) >= OFFER_NAME_LEN)
    {
        return false;
    }

    if (!pawn_public_exists(callback))
    {
        Log_Error("jobs","offer callback %s is not a public, %s is not registered",callback,name);
        return false;
    }

    for (new i = 0;i < s_OfferCounts[kind];i++)
    {
        if (!strcmp(s_OfferNames[kind][i],name,true))
        {
            strcopy(s_OfferCallbacks[kind][i],callback,JOBS_CALLBACK_LEN);
            return true;
        }
    }

    if (s_OfferCounts[kind] >= OFFER_MAX)
    {
        Log_Error("jobs","no room for offer %s: raise OFFER_MAX",name);
        return false;
    }

    new slot = s_OfferCounts[kind]++;
    strcopy(s_OfferNames[kind][slot],name,OFFER_NAME_LEN);
    strcopy(s_OfferCallbacks[kind][slot],callback,JOBS_CALLBACK_LEN);
    return true;
}

stock bool:Offer_RegisterAccept(const name[],const callback[])
{
    return Offer_Register(OFFER_KIND_ACCEPT,name,callback);
}

stock bool:Offer_RegisterCancel(const name[],const callback[])
{
    return Offer_Register(OFFER_KIND_CANCEL,name,callback);
}

stock bool:Service_Register(const name[],const callback[])
{
    return Offer_Register(OFFER_KIND_SERVICE,name,callback);
}

static Offer_Run(kind,playerid,const name[],const rest[],&result)
{
    for (new i = 0;i < s_OfferCounts[kind];i++)
    {
        if (!strcmp(s_OfferNames[kind][i],name,true))
        {
            result = pawn_call_public(s_OfferCallbacks[kind][i],"ds",playerid,rest);
            return true;
        }
    }

    return false;
}

stock Offer_Sweep(offerers[],leaving,size = MAX_PLAYERS)
{
    for (new i = 0;i < size;i++)
    {
        if (offerers[i] == leaving)
        {
            offerers[i] = OFFER_STALE;
        }
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
CMD:accept(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new name[32], rest[OFFER_REST_LEN];

    if (sscanf(params,"s[32]S()[128]",name,rest))
    {
        SendClientMessage(playerid,COLOR_WHITE,"|__________________ Accept __________________|");
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: accept [name]");
        SendClientMessage(playerid,COLOR_GREY,"Available names: Sex, Drugs, Repair, Lawyer, Bodyguard, Job, Live, Refill");
        SendClientMessage(playerid,COLOR_GREY,"Available names: Car, Taxi, Bus, Boxing, Medic, Mechanic, Paper, Ticket");
        SendClientMessage(playerid,COLOR_WHITE,"|____________________________________________|");
        return 1;
    }

    new result = 0;
    Offer_Run(OFFER_KIND_ACCEPT,playerid,name,rest,result);
    return 1;
}

CMD:cancel(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new name[32], rest[OFFER_REST_LEN];

    if (sscanf(params,"s[32]S()[128]",name,rest))
    {
        SendClientMessage(playerid,COLOR_WHITE,"|__________________ Cancel __________________|");
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /cancel [name]");
        SendClientMessage(playerid,COLOR_GREY,"Available names: Sex, Drugs, Repair, Lawyer, Bodyguard, Live, Refill, Car, Boxing");
        SendClientMessage(playerid,COLOR_GREY,"Available names: Taxi, Bus, Medic, Mechanic, Paper, Ticket, Witness, Marriage, Divorce");
        SendClientMessage(playerid,COLOR_WHITE,"|____________________________________________|");
        return 1;
    }

    new result = 0;

    if (Offer_Run(OFFER_KIND_CANCEL,playerid,name,rest,result) && result != 0)
    {
        new line[JOBS_LINE_LEN];
        format(line,sizeof(line),"* You have canceled: %s.",name);
        SendClientMessage(playerid,COLOR_YELLOW,line);
    }

    return 1;
}

CMD:service(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new name[32], rest[OFFER_REST_LEN];

    if (sscanf(params,"s[32]S()[128]",name,rest))
    {
        SendClientMessage(playerid,COLOR_WHITE,"|__________________ Service Names __________________|");
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /service [name]");
        SendClientMessage(playerid,COLOR_GREY,"Available names: Taxi, Bus, Medic, Mechanic");
        SendClientMessage(playerid,COLOR_WHITE,"|________________________________________________|");
        return 1;
    }

    new result = 0;

    if (!Offer_Run(OFFER_KIND_SERVICE,playerid,name,rest,result))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Unknown service name !");
    }

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
public Jobs_AcceptTicket(playerid,const params[])
{
    Law_AcceptTicket(playerid);
    return 1;
}

public Jobs_CancelTicket(playerid,const params[])
{
    Law_CancelTicket(playerid);
    return 1;
}
