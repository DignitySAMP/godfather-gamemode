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
static Medics_HealSelf(playerid,location)
{
    new house = Houses_FromLocal(location);

    if (house != HOUSE_NO_KEY)
    {
        if (Houses_HasArmourUpgrade(house) && Factions_IsCop(playerid))
        {
            Medics_BeginArmourRoom(playerid);
        }
        else
        {
            SendClientMessage(playerid,TEAM_GREEN_COLOR,"This place does not have armour upgrades.");
        }

        if (Houses_HasHealthUpgrade(house))
        {
            new Float:health;
            GetPlayerHealth(playerid,health);

            if (health < MEDICS_FULL_HEALTH)
            {
                SetPlayerHealth(playerid,MEDICS_FULL_HEALTH);
                PlayerPlaySound(playerid,MEDICS_HEAL_SOUND,0.0,0.0,0.0);
                SendClientMessage(playerid,TEAM_GREEN_COLOR,"You have been healed to 100 health.");
            }
            else
            {
                SendClientMessage(playerid,TEAM_GREEN_COLOR,"You are already healed to 100.");
            }
        }
        else
        {
            SendClientMessage(playerid,TEAM_GREEN_COLOR,"This place does not have healing upgrades.");
        }

        return true;
    }

    if (location == MEDICS_LOCAL_RESTAURANT)
    {
        new Float:health;
        GetPlayerHealth(playerid,health);

        if (health < MEDICS_FULL_HEALTH)
        {
            SetPlayerHealth(playerid,MEDICS_FULL_HEALTH);
            PlayerPlaySound(playerid,MEDICS_HEAL_SOUND,0.0,0.0,0.0);
            SendClientMessage(playerid,TEAM_GREEN_COLOR,"You have been healed to 100 health.");
        }
        else
        {
            SendClientMessage(playerid,TEAM_GREEN_COLOR,"You are already healed to 100.");
        }
    }
    else if (location == MEDICS_LOCAL_ARMOURY && Factions_IsCop(playerid))
    {
        SetPlayerHealth(playerid,MEDICS_FULL_HEALTH);
        Medics_BeginArmourRoom(playerid);
    }

    return false;
}

static Medics_HealPlayer(playerid,targetid,price)
{
    new Float:health;
    GetPlayerHealth(targetid,health);

    if (health >= MEDICS_FULL_HEALTH)
    {
        SendClientMessage(playerid,TEAM_GREEN_COLOR,"   That person is fully healed.");
        return;
    }

    new targetName[MAX_PLAYER_NAME + 1], line[96];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"~y~You healed ~n~~w~%s~n~~g~$%d",targetName,price);
    GameTextForPlayer(playerid,line,5000,1);
    Account_SetCash(playerid,Account_GetCash(playerid) + price);
    Account_SetCash(targetid,Account_GetCash(targetid) - price);

    new hp = 100, perk = Progress_GetPerk(playerid,PROGRESS_PERK_PAIN);

    if (perk > 0)
    {
        hp = 20 * perk + 100;
    }

    SetPlayerHealth(targetid,float(hp));
    PlayerPlaySound(playerid,MEDICS_HEAL_SOUND,0.0,0.0,0.0);
    PlayerPlaySound(targetid,MEDICS_HEAL_SOUND,0.0,0.0,0.0);
    format(line,sizeof(line),"You have been healed to %d health -$%d",hp,price);
    SendClientMessage(targetid,TEAM_GREEN_COLOR,line);
    pawn_call_public("Medics_OnHealed","dd",playerid,targetid);
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
CMD:heal(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid, priceText[16];

    if (sscanf(params,"u",targetid))
    {
        new location = Account_GetLocal(playerid);

        if (location == DOOR_LOCAL_OUTSIDE)
        {
            SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /heal [playerid/PartOfName] [price]");
            return 1;
        }

        if (Medics_HealSelf(playerid,location))
        {
            return 1;
        }

        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /heal [playerid/PartOfName] [price]");
        return 1;
    }

    if (sscanf(params,"{u}s[16]",priceText))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /heal [playerid/PartOfName] [price]");
        return 1;
    }

    new price = strval(priceText);

    if (price < 1 || price > MEDICS_HEAL_MAX_PRICE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Healing price not below 1 or above 1000 !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   You can not heal yourself!");
        return 1;
    }

    new line[80];

    if (targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid))
    {
        new typed[MAX_PLAYER_NAME + 1];
        Util_FirstWord(params,typed);
        format(line,sizeof(line),MEDICS_NOT_ACTIVE_FORMAT,typed);
        SendClientMessage(playerid,COLOR_GRAD1,line);
        return 1;
    }

    if (Factions_GetTeam(playerid) != TEAM_CYAN && !Factions_IsIn(playerid,FACTION_MEDICS))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   You are not authorized to use that command !");
        return 1;
    }

    new vehicleid = GetPlayerVehicleID(playerid);

    if (!Vehicles_IsAmbulance(vehicleid) || vehicleid != GetPlayerVehicleID(targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   One of you is not in the Ambulance / Chopper !");
        return 1;
    }

    Medics_HealPlayer(playerid,targetid,price);
    return 1;
}
