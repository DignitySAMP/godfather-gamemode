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

static Map:s_Offers[OFFER_KIND_COUNT];

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
static bool:Offer_Key(const name[],dest[OFFER_NAME_LEN])
{
    if (name[0] == EOS || strlen(name) >= OFFER_NAME_LEN)
    {
        dest[0] = EOS;
        return false;
    }

    strcopy(dest,name,OFFER_NAME_LEN);

    for (new i = 0;dest[i] != EOS;i++)
    {
        dest[i] = tolower(dest[i]);
    }

    return true;
}

static bool:Offer_Find(kind,const name[],dest[],size = sizeof(dest))
{
    new key[OFFER_NAME_LEN];
    dest[0] = EOS;

    if (kind < 0 || kind >= OFFER_KIND_COUNT || !map_valid(s_Offers[kind]) || !Offer_Key(name,key) || !map_has_str_key(s_Offers[kind],key))
    {
        return false;
    }

    map_str_get_str(s_Offers[kind],key,dest,size);
    return true;
}

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

    new key[OFFER_NAME_LEN], stored[JOBS_CALLBACK_LEN];
    Offer_Key(name,key);
    strcopy(stored,callback,JOBS_CALLBACK_LEN);

    if (!map_valid(s_Offers[kind]))
    {
        s_Offers[kind] = map_new();
    }

    map_str_remove(s_Offers[kind],key);
    map_str_add_str(s_Offers[kind],key,stored);
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
    new callback[JOBS_CALLBACK_LEN];

    if (!Offer_Find(kind,name,callback))
    {
        return false;
    }

    result = pawn_call_public(callback,"ds",playerid,rest);
    return true;
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
