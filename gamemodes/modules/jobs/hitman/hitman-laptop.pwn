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
#define HITMAN_PACKAGE_COUNT (7)
#define HITMAN_TOKEN_LEN (32)
#define HITMAN_NEWS_RANK_WRITE (3)
#define HITMAN_NEWS_RANK_DELETE (4)
#define HITMAN_NEWS_TEXT_FROM (7)
#define HITMAN_NEWS_MIN_TEXT (10)
#define HITMAN_RANK_CONTRACTS (4)
#define HITMAN_HQ_RADIUS (2.0)

static const s_HitmanPackageRanks[HITMAN_PACKAGE_COUNT] = {1, 2, 2, 3, 3, 4, 4};
static const s_HitmanPackagePrices[HITMAN_PACKAGE_COUNT] = {5000, 6000, 6000, 8000, 8000, 8500, 8500};

forward Hitman_ChatLaptop(playerid,const text[]);
forward Hitman_PickupPackage(playerid);

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
static Hitman_SendMenu(playerid)
{
    SendClientMessage(playerid,COLOR_WHITE,"|___ Hitman Agency ___|");
    SendClientMessage(playerid,COLOR_YELLOW2,"| - News");
    SendClientMessage(playerid,COLOR_YELLOW2,"| - Contracts");
    SendClientMessage(playerid,COLOR_YELLOW2,"| - Givehit");
    SendClientMessage(playerid,COLOR_YELLOW2,"| - Backup");
    SendClientMessage(playerid,COLOR_YELLOW2,"| - Order");
    SendClientMessage(playerid,COLOR_YELLOW2,"| - Ranks");
    SendClientMessage(playerid,COLOR_YELLOW2,"| - Logout");
    SendClientMessage(playerid,COLOR_YELLOW2,"|");
    SendClientMessage(playerid,COLOR_WHITE,"|______________|00:00|");
}

static Hitman_NewsBoard(playerid)
{
    new line[JOBS_LINE_LEN], text[HITMAN_NEWS_LEN], contact[HITMAN_NEWS_LEN];
    SendClientMessage(playerid,COLOR_WHITE,"|__________________ Hitman Agency News __________________|");
    SendClientMessage(playerid,COLOR_WHITE,"USAGE: News [number] or News delete [number] or News delete all");

    for (new slot = 0;slot < HITMAN_NEWS_SLOTS;slot++)
    {
        Hitman_GetNewsText(slot,text);
        Hitman_GetNewsContact(slot,contact);
        format(line,sizeof(line),"%d: %s :: Hitman: %s",slot + 1,text,contact);
        SendClientMessage(playerid,COLOR_GREY,line);
    }

    SendClientMessage(playerid,COLOR_WHITE,"|________________________________________________________|");
}

static Hitman_NewsPlace(playerid,slot,const text[])
{
    new line[JOBS_LINE_LEN];

    if (Hitman_HasPlacedNews(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Already placed a News Message, it must be deleted first !");
        return;
    }

    if (Factions_GetRank(playerid) < HITMAN_NEWS_RANK_WRITE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You must be Rank 3 to write messages to the News Channel !");
        return;
    }

    if (Hitman_IsNewsTaken(slot))
    {
        format(line,sizeof(line),"   Spot %d is already Taken !",slot + 1);
        SendClientMessage(playerid,COLOR_GREY,line);
        return;
    }

    if (strlen(text) < HITMAN_NEWS_MIN_TEXT)
    {
        SendClientMessage(playerid,COLOR_GREY,"   News Text too short !");
        return;
    }

    new body[HITMAN_NEWS_LEN], name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));
    strmid(body,text,HITMAN_NEWS_TEXT_FROM,strlen(text),HITMAN_NEWS_LEN);
    Hitman_PlaceNews(slot,body,name);
    Hitman_SetPlacedNews(playerid,true);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You placed a News Message on the Hitman Agency's News Channel.");
}

static Hitman_NewsDelete(playerid,const text[],&at)
{
    if (Factions_GetRank(playerid) < HITMAN_NEWS_RANK_DELETE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You must be Rank 4 to delete messages from the News Channel !");
        return;
    }

    new token[HITMAN_TOKEN_LEN], line[JOBS_LINE_LEN];

    if (!Util_ReadToken(text,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: News delete [number] or News delete all.");
        return;
    }

    if (!strcmp(token,"all",true))
    {
        for (new slot = 0;slot < HITMAN_NEWS_SLOTS;slot++)
        {
            Hitman_ClearNews(slot);
        }

        SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You deleted all the News Message from the Hitman Agency's News Channel.");
        return;
    }

    for (new slot = 0;slot < HITMAN_NEWS_SLOTS;slot++)
    {
        format(line,sizeof(line),"%d",slot + 1);

        if (!strcmp(token,line,true))
        {
            Hitman_ClearNews(slot);
            format(line,sizeof(line),"* You deleted News Message (%d) from the Hitman Agency's News Channel.",slot + 1);
            SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
            return;
        }
    }

    SendClientMessage(playerid,COLOR_WHITE,"USAGE: News delete [number] or News delete all.");
}

static Hitman_News(playerid,const text[],&at)
{
    new token[HITMAN_TOKEN_LEN];

    if (!Util_ReadToken(text,at,token))
    {
        Hitman_NewsBoard(playerid);
        return;
    }

    if (!strcmp(token,"delete",true))
    {
        Hitman_NewsDelete(playerid,text,at);
        return;
    }

    for (new slot = 0;slot < HITMAN_NEWS_SLOTS;slot++)
    {
        new number[4];
        format(number,sizeof(number),"%d",slot + 1);

        if (!strcmp(token,number,true))
        {
            Hitman_NewsPlace(playerid,slot,text);
            return;
        }
    }
}

static Hitman_GiveHit(playerid,const text[],&at)
{
    if (Factions_GetRank(playerid) < HITMAN_RANK_CONTRACTS)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You need Rank 4 to Give Contracts to Hitmans !");
        return;
    }

    if (!Hitman_IsHitFound())
    {
        SendClientMessage(playerid,COLOR_GREY,"   There is no Hit Found yet, use Contracts in the Portable first !");
        return;
    }

    new token[HITMAN_TOKEN_LEN];

    if (!Util_ReadToken(text,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: Givehit [playerid/PartOfName]");
        return;
    }

    new hitmanid;
    sscanf(token,"u",hitmanid);

    if (!Util_IsValidPlayer(hitmanid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That Hitman is not Online, or ain't a Hitman !");
        return;
    }

    if (Factions_GetMember(hitmanid) != FACTION_HITMAN)
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not a Hitman !");
        return;
    }

    if (Hitman_GetChase(hitmanid) != HITMAN_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   That Hitman is already busy with a Contract !");
        return;
    }

    new victimid = Hitman_GetFoundId();

    if (!Util_IsValidPlayer(victimid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   The Contracted Person is offline, use Contracts in the Portable again !");
        return;
    }

    new line[JOBS_LINE_LEN], name[MAX_PLAYER_NAME + 1], hitmanName[MAX_PLAYER_NAME + 1], victimName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(hitmanid,hitmanName,sizeof(hitmanName));
    GetPlayerName(victimid,victimName,sizeof(victimName));
    format(line,sizeof(line),"* Hitman %s, assigned Hitman %s to kill: %s(ID:%d), for $%d.",name,hitmanName,victimName,victimid,Hitman_GetHeadValue(victimid));
    Hitman_SendAgency(COLOR_YELLOW,line);
    Hitman_SetChase(hitmanid,victimid);
    Hitman_SetChased(victimid,hitmanid);
    Hitman_SetHit(victimid,true);
    Hitman_SetFound(false,HITMAN_NONE);
}

static Hitman_Ranks(playerid)
{
    new line[JOBS_LINE_LEN], name[MAX_PLAYER_NAME + 1];
    SendClientMessage(playerid,COLOR_WHITE,"|__________________ Agency's Ranks __________________|");

    foreach (new targetid : Player)
    {
        if (Factions_IsIn(targetid,FACTION_HITMAN))
        {
            GetPlayerName(targetid,name,sizeof(name));
            format(line,sizeof(line),"* %s: Rank %d",name,Factions_GetRank(targetid));
            SendClientMessage(playerid,COLOR_GREY,line);
        }
    }
}

static Hitman_PackageList(playerid)
{
    new rank = Factions_GetRank(playerid);
    SendClientMessage(playerid,COLOR_WHITE,"|__________________ Available Packages __________________|");

    if (rank >= 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"|(1) ($5000 ) Rank 1 - 5: Knife, Desert Eagle, MP5, Shotgun");
    }

    if (rank >= 2)
    {
        SendClientMessage(playerid,COLOR_GREY,"|(2) ($6000 ) Rank 2 - 5: Knife, Desert Eagle, M4, MP5, Shotgun");
        SendClientMessage(playerid,COLOR_GREY,"|(3) ($6000 ) Rank 2 - 5: Knife, Desert Eagle, AK47, MP5, Shotgun");
    }

    if (rank >= 3)
    {
        SendClientMessage(playerid,COLOR_GREY,"|(4) ($8000) Rank 3 - 5: Knife, Desert Eagle, M4, MP5, Shotgun, Sniper");
        SendClientMessage(playerid,COLOR_GREY,"|(5) ($8000) Rank 3 - 5: Knife, Desert Eagle, AK47, MP5, Shotgun, Sniper");
    }

    if (rank >= 4)
    {
        SendClientMessage(playerid,COLOR_GREY,"|(6) ($8500) Rank 4 - 5: Knife, Desert Eagle, M4, MP5, Shotgun, Sniper");
        SendClientMessage(playerid,COLOR_GREY,"|(7) ($8500) Rank 4 - 5: Knife, Desert Eagle, AK47, MP5, Shotgun, Sniper");
    }

    SendClientMessage(playerid,COLOR_WHITE,"|________________________________________________________|");
}

static Hitman_Order(playerid,const text[],&at)
{
    if (Hitman_GetOrder(playerid) > 0)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You already Ordered a Package, pick it up at your Head Quarter's Front Door first !");
        return;
    }

    new token[HITMAN_TOKEN_LEN], line[JOBS_LINE_LEN];
    Util_ReadToken(text,at,token);

    for (new package = 0;package < HITMAN_PACKAGE_COUNT;package++)
    {
        format(line,sizeof(line),"%d",package + 1);

        if (strcmp(token,line,true) != 0)
        {
            continue;
        }

        if (Factions_GetRank(playerid) < s_HitmanPackageRanks[package])
        {
            SendClientMessage(playerid,COLOR_GREY,"   Your Rank is not high enough to Order that Package !");
            return;
        }

        if (Account_GetCash(playerid) < s_HitmanPackagePrices[package])
        {
            SendClientMessage(playerid,COLOR_GREY,"   You can't afford that Package !");
            return;
        }

        format(line,sizeof(line),"* You have Ordered Package %d ($%d), it will be delivered at your Head Quarter's Front Door.",package + 1,s_HitmanPackagePrices[package]);
        SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
        Hitman_SetOrder(playerid,package + 1);
        return;
    }

    Hitman_PackageList(playerid);
}

static Hitman_RunLaptop(playerid,const text[])
{
    new at = 0, token[HITMAN_TOKEN_LEN];
    Util_ReadToken(text,at,token);

    if (!strcmp(token,"Contracts",true))
    {
        if (Factions_GetRank(playerid) < HITMAN_RANK_CONTRACTS)
        {
            SendClientMessage(playerid,COLOR_GREY,"   Only Hitman with Rank 4 or above can search and assign Contracts !");
            return;
        }

        Hitman_Search(playerid);
    }
    else if (!strcmp(token,"News",true))
    {
        Hitman_News(playerid,text,at);
    }
    else if (!strcmp(token,"Givehit",true))
    {
        Hitman_GiveHit(playerid,text,at);
    }
    else if (!strcmp(token,"Ranks",true))
    {
        Hitman_Ranks(playerid);
    }
    else if (!strcmp(token,"Order",true))
    {
        Hitman_Order(playerid,text,at);
    }
    else if (!strcmp(token,"Logout",true))
    {
        SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You have shutdowned your Laptop, and Disconnected from your Agency.");
        Factions_SetOnLaptop(playerid,false);
    }
    else
    {
        Hitman_SendMenu(playerid);
    }
}

static Hitman_GivePackage(playerid,package)
{
    GivePlayerWeapon(playerid,WEAPON:24,50);
    GivePlayerWeapon(playerid,WEAPON:29,500);
    GivePlayerWeapon(playerid,WEAPON:25,50);

    if (package == 2 || package == 4 || package == 6)
    {
        GivePlayerWeapon(playerid,WEAPON:31,500);
    }
    else if (package == 3 || package == 5 || package == 7)
    {
        GivePlayerWeapon(playerid,WEAPON:30,500);
    }

    GivePlayerWeapon(playerid,WEAPON:4,1);

    if (package >= 4)
    {
        GivePlayerWeapon(playerid,WEAPON:34,20);
    }
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
public Hitman_ChatLaptop(playerid,const text[])
{
    if (!Factions_IsOnLaptop(playerid))
    {
        return 0;
    }

    Hitman_RunLaptop(playerid,text);
    return 1;
}

public Hitman_PickupPackage(playerid)
{
    new package = Hitman_GetOrder(playerid);

    if (package <= 0 || package > HITMAN_PACKAGE_COUNT)
    {
        return 1;
    }

    Hitman_GivePackage(playerid,package);
    Account_SetCash(playerid,Account_GetCash(playerid) - s_HitmanPackagePrices[package - 1]);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You picked up your Ordered Package.");
    Hitman_SetOrder(playerid,0);
    return 1;
}
