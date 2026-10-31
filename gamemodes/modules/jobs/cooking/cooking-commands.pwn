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
static bool:Cooking_ReadSlot(playerid,const numberText[],&number)
{
    number = strval(numberText);

    if (number < 1 || number > COOKING_SLOTS)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Cook number can't be below 1 or above 5 !");
        return false;
    }

    if (Cooking_GetWeight(playerid,number) < 1)
    {
        new line[COOKING_LINE_LEN];
        format(line,sizeof(line),"   You didn't even Cook something at that number(%d) !",number);
        SendClientMessage(playerid,COLOR_GREY,line);
        return false;
    }

    return true;
}

static bool:Cooking_Add(playerid,const name[],weight,cookId)
{
    new slot = Cooking_FindFree(playerid);

    if (slot == 0)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You don't have any space in your Cooking List !");
        return false;
    }

    Cooking_SetSlot(playerid,slot,name,weight,cookId);

    new line[COOKING_LINE_LEN];
    format(line,sizeof(line),"* You've made %s, weighing %d LBS.",name,weight);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    return true;
}

static bool:Cooking_CookFish(playerid,fishId,weight)
{
    new fishName[FISHING_NAME_LEN], name[COOKING_NAME_LEN];
    Fishing_GetFishName(fishId,fishName);
    format(name,sizeof(name),"A Cooked %s",fishName);
    return Cooking_Add(playerid,name,weight,fishId);
}

static Cooking_CookGrocery(playerid,kind,weightKind,place,const placeText[],const missingText[],const name[])
{
    if (Cooking_FindPlace(playerid) != place)
    {
        SendClientMessage(playerid,COLOR_GREY,placeText);
        return;
    }

    if (Cooking_GetGroceryWeight(playerid,kind) == 0)
    {
        SendClientMessage(playerid,COLOR_GREY,missingText);
        return;
    }

    if (Cooking_Add(playerid,name,Cooking_GetGroceryWeight(playerid,weightKind),COOKING_GROCERY_ID))
    {
        Cooking_SetGrocery(playerid,kind,0,0);
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
CMD:cooked(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new line[COOKING_LINE_LEN], name[COOKING_NAME_LEN];
    SendClientMessage(playerid,COLOR_WHITE,"|__________________ Cooking __________________|");

    for (new number = 1;number <= COOKING_SLOTS;number++)
    {
        Cooking_GetName(playerid,number,name);
        format(line,sizeof(line),"** (%d) Made: %s.   Weight: %d.",number,name,Cooking_GetWeight(playerid,number));
        SendClientMessage(playerid,COLOR_GREY,line);
    }

    SendClientMessage(playerid,COLOR_WHITE,"|____________________________________________|");
    return 1;
}

CMD:cook(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Cooking_IsAtPlace(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not at one of the Cooking Places (Cluckin Bell / Burger Shot / Well Stacked Pizza).");
        return 1;
    }

    new what[16], rest[16];

    if (sscanf(params,"s[16]S()[16]",what,rest))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /cook [name]");
        SendClientMessage(playerid,COLOR_WHITE,"Available names: Lastfish, Fish, Chicken, Hamburger, Pizza.");
        return 1;
    }

    if (!strcmp(what,"lastfish",true))
    {
        new slot = Fishing_GetLastSlot(playerid);

        if (slot < 1)
        {
            SendClientMessage(playerid,COLOR_GREY,"   You haven't even caught a Fish yet !");
            return 1;
        }

        if (Cooking_CookFish(playerid,Fishing_GetLastFish(playerid),Fishing_GetLastWeight(playerid)))
        {
            Fishing_ClearSlot(playerid,slot);
            Fishing_ClearLast(playerid);
        }
    }
    else if (!strcmp(what,"fish",true))
    {
        if (rest[0] == EOS)
        {
            SendClientMessage(playerid,COLOR_WHITE,"USAGE: /cook fish [fishnumber]");
            return 1;
        }

        new number = strval(rest);

        if (number < 1 || number > FISHING_SLOTS)
        {
            SendClientMessage(playerid,COLOR_GREY,"   Fish number can't be below 1 or above 5 !");
            return 1;
        }

        if (Fishing_GetWeight(playerid,number) < 1)
        {
            new line[COOKING_LINE_LEN];
            format(line,sizeof(line),"   You didn't even catch a Fish at that number(%d) !",number);
            SendClientMessage(playerid,COLOR_GREY,line);
            return 1;
        }

        if (Cooking_CookFish(playerid,Fishing_GetFishId(playerid,number),Fishing_GetWeight(playerid,number)))
        {
            Fishing_ClearSlot(playerid,number);
            Fishing_ClearLast(playerid);
        }
    }
    else if (!strcmp(what,"chicken",true))
    {
        Cooking_CookGrocery(playerid,SHOPS_GROCERY_CHICKEN,SHOPS_GROCERY_CHICKEN,COOKING_PLACE_CLUCKIN,"   You need to be at Cluckin Bell to Cook this !","   You don't have any Chickens with you !","A Cooked Chicken");
    }
    else if (!strcmp(what,"hamburger",true))
    {
        Cooking_CookGrocery(playerid,SHOPS_GROCERY_HAMBURGER,SHOPS_GROCERY_HAMBURGER,COOKING_PLACE_BURGER,"   You need to be at Burger Shot to Cook this !","   You don't have any Hamburgers with you !","A Cooked Hamburger");
    }
    else if (!strcmp(what,"pizza",true))
    {
        Cooking_CookGrocery(playerid,SHOPS_GROCERY_PIZZA,SHOPS_GROCERY_PIZZA,COOKING_PLACE_PIZZA,"   You need to be at Well Stacked Pizza to Cook this !","   You don't have any Pizzas with you !","A Cooked Pizza");
    }
    else
    {
        SendClientMessage(playerid,COLOR_GREY,"   Invalid Cooking Name !");
    }

    return 1;
}

CMD:eat(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (Cooking_IsFighting(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Can't eat a Fish while you are fighting !");
        return 1;
    }

    new numberText[16];

    if (sscanf(params,"s[16]",numberText))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /eat [cook number]");
        return 1;
    }

    new number;

    if (!Cooking_ReadSlot(playerid,numberText,number))
    {
        return 1;
    }

    new Float:health;
    GetPlayerHealth(playerid,health);

    if (!(health < COOKING_EAT_HEALTH))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Your health is high enough, can only eat at 40 Health !");
        return 1;
    }

    new cookId = Cooking_GetId(playerid,number), weight = Cooking_GetWeight(playerid,number), cooked[COOKING_NAME_LEN], playerName[MAX_PLAYER_NAME + 1], line[COOKING_LINE_LEN];
    Cooking_GetName(playerid,number,cooked);
    GetPlayerName(playerid,playerName,sizeof(playerName));

    if (cookId == COOKING_ENDANGERED_DOLPHIN || cookId == COOKING_ENDANGERED_TURTLE)
    {
        Law_AddCrime(playerid,COOKING_ENDANGERED_POINTS,INVALID_PLAYER_ID,"Consuming endangered Species");
    }

    SetPlayerHealth(playerid,health + float(weight / COOKING_EAT_DIVIDER));
    format(line,sizeof(line),"* %s eats %s.",playerName,cooked);
    Chat_ProxDetector(COOKING_EAT_RANGE,playerid,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
    format(line,sizeof(line),"* You ate %s weighing %d, and it was added to your Health.",cooked,weight);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    Cooking_ClearSlot(playerid,number);
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
public Cooking_SellCooked(playerid,const params[])
{
    new numberText[16], targetText[32];

    if (sscanf(params,"s[16]S()[32]",numberText,targetText))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /sell cooked [cooknumber] [playerid/PartOfName]");
        return 1;
    }

    new number;

    if (!Cooking_ReadSlot(playerid,numberText,number))
    {
        return 1;
    }

    new targetid;

    if (targetText[0] == EOS || sscanf(targetText,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /sell cooked [cooknumber] [playerid/PartOfName]");
        return 1;
    }

    if (!Util_IsValidPlayer(targetid) || !IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    new slot = Cooking_FindFree(targetid);

    if (slot == 0)
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player has no space left in his Cooking List !");
        return 1;
    }

    new cooked[COOKING_NAME_LEN], weight = Cooking_GetWeight(playerid,number), cookId = Cooking_GetId(playerid,number);
    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[COOKING_LINE_LEN];
    Cooking_GetName(playerid,number,cooked);
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    Cooking_SetSlot(targetid,slot,cooked,weight,cookId);
    format(line,sizeof(line),"* %s has given you %s weighing %d (use /cooked to see it).",name,cooked,weight);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* You gave %s weighing %d to %s.",cooked,weight,targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    Cooking_ClearSlot(playerid,number);
    return 1;
}
