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
#define GET_NAME_LEN (16)
#define GET_REST_LEN (64)

static Map:s_GetOptions;

forward Drugs_GetDrugs(playerid,const params[]);
forward Drugs_GetFuel(playerid,const params[]);

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
static bool:Get_Key(const name[],dest[GET_NAME_LEN])
{
    if (name[0] == EOS || strlen(name) >= GET_NAME_LEN)
    {
        dest[0] = EOS;
        return false;
    }

    strcopy(dest,name,GET_NAME_LEN);

    for (new i = 0;dest[i] != EOS;i++)
    {
        dest[i] = tolower(dest[i]);
    }

    return true;
}

static bool:Get_Find(const name[],dest[],size = sizeof(dest))
{
    new key[GET_NAME_LEN];
    dest[0] = EOS;

    if (!map_valid(s_GetOptions) || !Get_Key(name,key) || !map_has_str_key(s_GetOptions,key))
    {
        return false;
    }

    map_str_get_str(s_GetOptions,key,dest,size);
    return true;
}

stock bool:Get_Register(const name[],const callback[])
{
    if (name[0] == EOS || strlen(name) >= GET_NAME_LEN)
    {
        return false;
    }

    if (!pawn_public_exists(callback))
    {
        Log_Error("drugs","get callback %s is not a public, %s is not registered",callback,name);
        return false;
    }

    new key[GET_NAME_LEN], stored[JOBS_CALLBACK_LEN];
    Get_Key(name,key);
    strcopy(stored,callback,JOBS_CALLBACK_LEN);

    if (!map_valid(s_GetOptions))
    {
        s_GetOptions = map_new();
    }

    map_str_remove(s_GetOptions,key);
    map_str_add_str(s_GetOptions,key,stored);
    return true;
}

static Get_Run(playerid,const name[],const rest[])
{
    new callback[JOBS_CALLBACK_LEN];

    if (Get_Find(name,callback))
    {
        pawn_call_public(callback,"ds",playerid,rest);
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
CMD:get(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new name[32], rest[GET_REST_LEN];

    if (sscanf(params,"s[32]S()[64]",name,rest))
    {
        SendClientMessage(playerid,COLOR_WHITE,"|__________________ Get __________________|");
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /get [name]");
        SendClientMessage(playerid,COLOR_GREY,"Available names: Drugs, Fuel");
        SendClientMessage(playerid,COLOR_GREEN,"|_________________________________________|");
        return 1;
    }

    Get_Run(playerid,name,rest);
    return 1;
}

CMD:selldrugs(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Jobs_Is(playerid,JOB_DRUGS))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Drugs Dealer!");
        return 1;
    }

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /selldrugs [playerid/PartOfName] [amount] [price]");
        return 1;
    }

    new gramsText[16], priceText[16];
    sscanf(params,"{u}S()[16]S()[16]",gramsText,priceText);

    if (gramsText[0] == EOS)
    {
        return 1;
    }

    new grams = strval(gramsText);

    if (grams < 1 || grams > DRUGS_GRAMS_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Grams not lower than 1, or above 99!");
        return 1;
    }

    if (priceText[0] == EOS)
    {
        return 1;
    }

    new price;

    if (!Jobs_ReadPrice(priceText,price))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Price not lower than 1, or above 99999!");
        return 1;
    }

    if (grams > Drugs_GetStock(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You don't have that much Drugs with you !");
        return 1;
    }

    if (!Util_IsValidPlayer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is offline.");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,DRUGS_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Can't sell to yourself!");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You offered %s to buy %d gram of drugs for $%d .",targetName,grams,price);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* Drug Dealer %s wants to sell you %d gram for $%d, (type /accept drugs) to buy.",name,grams,price);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    Drugs_SetOffer(targetid,playerid,price,grams);
    return 1;
}

CMD:usedrugs(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Boxing_IsFighting(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Can't use Drugs while you are fighting !");
        return 1;
    }

    if (Drugs_GetStock(playerid) <= 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You don't have any Drug Grams left !");
        return 1;
    }

    Drugs_SetStoned(playerid,Drugs_GetStoned(playerid) + 1);

    if (Drugs_GetStoned(playerid) >= 2)
    {
        GameTextForPlayer(playerid,"~w~You are~n~~p~Stoned",4000,1);
    }

    new Float:health, perk = Progress_GetPerk(playerid,PROGRESS_PERK_DRUG);
    GetPlayerHealth(playerid,health);
    SetPlayerHealth(playerid,health + 20.0 + float(2 * perk));
    SendClientMessage(playerid,COLOR_GREY,"   2 Drug Grams used !");
    Drugs_SetStock(playerid,Drugs_GetStock(playerid) - DRUGS_USE_GRAMS);

    switch (Whore_GetDisease(playerid))
    {
        case WHORE_DISEASE_CHLAMYDIA:
        {
            Whore_SetDisease(playerid,WHORE_DISEASE_NONE);
            SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You are no longer infected with a STD anymore because of the Drugs !");
        }
        case WHORE_DISEASE_GONORRHEA:
        {
            Whore_SetDisease(playerid,WHORE_DISEASE_CHLAMYDIA);
            SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You lowered the STD to Chlamydia because of the Drugs !");
        }
        case WHORE_DISEASE_SYPHILIS:
        {
            Whore_SetDisease(playerid,WHORE_DISEASE_GONORRHEA);
            SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You lowered the STD to Gonorrhea because of the Drugs !");
        }
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
public Drugs_GetDrugs(playerid,const params[])
{
    new carried = Drugs_GetStock(playerid), line[JOBS_LINE_LEN];

    if (carried > DRUGS_CARRY_LIMIT)
    {
        format(line,sizeof(line),"  You still have %d grams with you, sell them first !",carried);
        SendClientMessage(playerid,COLOR_GREY,line);
        return 1;
    }

    if (params[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /get drugs [amount]");
        return 1;
    }

    new price, maxGrams, grams = strval(params);
    Drugs_GetPriceTier(Progress_GetSkill(playerid,PROGRESS_SKILL_DRUGS),price,maxGrams);

    if (grams < 1 || grams > maxGrams)
    {
        format(line,sizeof(line),"   You can't go below 1 or above %d at your Skill Level!",maxGrams);
        SendClientMessage(playerid,COLOR_GREY,line);
        return 1;
    }

    if (!Jobs_Is(playerid,JOB_DRUGS) || !Drugs_IsAtHouse(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Drugs Dealer, or not at the Cracker House !");
        return 1;
    }

    new cost = grams * price;

    if (Account_GetCash(playerid) < cost)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You can't afford the Drugs !");
        return 1;
    }

    format(line,sizeof(line),"* You bought %d grams for $%d.",grams,cost);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    Account_SetCash(playerid,Account_GetCash(playerid) - cost);
    Drugs_SetStock(playerid,grams);
    return 1;
}

public Drugs_GetFuel(playerid,const params[])
{
    Fuel_BuyCan(playerid);
    return 1;
}
