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
static bool:Fishing_ReadSlot(playerid,const params[],const usage[],&number)
{
    new numberText[16];

    if (sscanf(params,"s[16]",numberText))
    {
        SendClientMessage(playerid,COLOR_WHITE,usage);
        return false;
    }

    number = strval(numberText);

    if (number < 1 || number > FISHING_SLOTS)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Fish number can't be below 1 or above 5 !");
        return false;
    }

    if (Fishing_GetWeight(playerid,number) < 1)
    {
        new line[FISHING_LINE_LEN];
        format(line,sizeof(line),"   You didn't even catch a Fish at that number(%d) !",number);
        SendClientMessage(playerid,COLOR_GREY,line);
        return false;
    }

    return true;
}

static Fishing_AnnounceSkill(playerid,skill)
{
    switch (skill)
    {
        case FISHING_SKILL_LEVEL_2:
        {
            SendClientMessage(playerid,COLOR_YELLOW,"* Your Fishing Skill is now Level 2, you can now catch Heavier Fishes.");
        }
        case FISHING_SKILL_LEVEL_3:
        {
            SendClientMessage(playerid,COLOR_YELLOW,"* Your Fishing Skill is now Level 3, you can now catch Heavier Fishes.");
        }
        case FISHING_SKILL_LEVEL_4:
        {
            SendClientMessage(playerid,COLOR_YELLOW,"* Your Fishing Skill is now Level 4, you can now catch Heavier Fishes.");
        }
        case FISHING_SKILL_LEVEL_5:
        {
            SendClientMessage(playerid,COLOR_YELLOW,"* Your Fishing Skill is now Level 5, you can now catch Heavier Fishes.");
        }
    }
}

static Fishing_RollWeight(skill)
{
    if (skill <= 50)
    {
        return random(20) - 7;
    }

    if (skill <= 100)
    {
        return random(50) - 20;
    }

    if (skill <= 200)
    {
        return random(100) - 50;
    }

    if (skill <= 400)
    {
        return random(160) - 60;
    }

    return random(180) - 70;
}

static bool:Fishing_ThrowJunk(playerid,fishId)
{
    switch (fishId)
    {
        case 0:
        {
            SendClientMessage(playerid,COLOR_GREY,"   You caught a Jacket and threw it away !");
        }
        case 4:
        {
            SendClientMessage(playerid,COLOR_GREY,"   You caught a Pants and threw it away !");
        }
        case 7:
        {
            SendClientMessage(playerid,COLOR_GREY,"   You caught a Can and threw it away !");
        }
        case 10:
        {
            SendClientMessage(playerid,COLOR_GREY,"   You caught a pair of Shoes and threw it away !");
        }
        case 13:
        {
            SendClientMessage(playerid,COLOR_GREY,"   You caught some Garbage and threw it away !");
        }
        default:
        {
            return false;
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
CMD:fish(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Fishing_GetCaught(playerid) > FISHING_CAUGHT_LIMIT)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Caught too many fish, wait till it's reduced !");
        return 1;
    }

    if (Fishing_IsFull(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You already caught 5 Fishes, sell / eat / release them first !");
        return 1;
    }

    if (!Fishing_IsAtPlace(playerid) && !Vehicles_IsBoat(GetPlayerVehicleID(playerid)))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not at a Fishing Place (Big Wheel Rods) or on a Fishing Boat !");
        return 1;
    }

    new caught = Fishing_RollWeight(Progress_GetSkill(playerid,PROGRESS_SKILL_FISH)), fishId = random(FISHING_NAME_COUNT), line[FISHING_LINE_LEN];

    if (caught <= 0)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Line snapped !");
        return 1;
    }

    if (Fishing_ThrowJunk(playerid,fishId))
    {
        return 1;
    }

    if (fishId == FISHING_MONEY_BAG)
    {
        new money = random(FISHING_MONEY_BAG_MAX);
        format(line,sizeof(line),"* You caught a Money Bag, containing $%d.",money);
        SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
        Account_SetCash(playerid,Account_GetCash(playerid) + money);
        return 1;
    }

    if (!License_Has(playerid,LICENSE_FISH))
    {
        Law_AddCrime(playerid,1,INVALID_PLAYER_ID,"Illegal Fishing");
    }

    new slot = Fishing_FindFree(playerid);

    if (slot == 0)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You don't have any space for your Fish !");
        return 1;
    }

    Fishing_SetCaught(playerid,Fishing_GetCaught(playerid) + 1);
    new skill = Progress_AddSkill(playerid,PROGRESS_SKILL_FISH), name[FISHING_NAME_LEN];
    Fishing_SetSlot(playerid,slot,fishId,caught);
    Fishing_GetName(playerid,slot,name);
    format(line,sizeof(line),"* You have caught a %s, which weighs %d Lbs.",name,caught);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    Fishing_SetLast(playerid,slot,fishId,caught);

    if (caught > Fishing_GetBiggest(playerid))
    {
        format(line,sizeof(line),"* Your old record of %d Lbs has been passed, your new Biggest Fish is: %d Lbs.",Fishing_GetBiggest(playerid),caught);
        SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
        Fishing_SetBiggest(playerid,caught);
    }

    Fishing_AnnounceSkill(playerid,skill);
    return 1;
}

CMD:fishes(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new line[FISHING_LINE_LEN], name[FISHING_NAME_LEN];
    SendClientMessage(playerid,COLOR_WHITE,"|__________________ Fishes __________________|");

    for (new number = 1;number <= FISHING_SLOTS;number++)
    {
        Fishing_GetName(playerid,number,name);
        format(line,sizeof(line),"** (%d) Fish: %s.   Weight: %d.",number,name,Fishing_GetWeight(playerid,number));
        SendClientMessage(playerid,COLOR_GREY,line);
    }

    SendClientMessage(playerid,COLOR_WHITE,"|____________________________________________|");
    return 1;
}

CMD:releasefish(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new number;

    if (!Fishing_ReadSlot(playerid,params,"USAGE: /releasefish [fish]",number))
    {
        return 1;
    }

    Fishing_ClearSlot(playerid,number);
    Fishing_ClearLast(playerid);
    return 1;
}

CMD:throwback(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new slot = Fishing_GetLastSlot(playerid);

    if (slot < 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You haven't even caught a Fish yet !");
        return 1;
    }

    Fishing_ClearSlot(playerid,slot);
    Fishing_ClearLast(playerid);
    return 1;
}

CMD:throwbackall(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!Fishing_HasAny(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You haven't even caught a Fish yet !");
        return 1;
    }

    Fishing_ClearAll(playerid);
    Fishing_ClearLast(playerid);
    return 1;
}
