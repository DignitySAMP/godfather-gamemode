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
CMD:materials(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Jobs_Is(playerid,JOB_ARMS))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not an Arms Dealer !");
        return 1;
    }

    new name[16], rest[16];

    if (sscanf(params,"s[16]S()[16]",name,rest))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /materials [name]");
        SendClientMessage(playerid,COLOR_WHITE,"Available names: Get, Deliver.");
        return 1;
    }

    new line[JOBS_LINE_LEN];

    if (!strcmp(name,"get",true))
    {
        if (!Arms_IsAtShop(playerid))
        {
            SendClientMessage(playerid,COLOR_GREY,"   You are not at the Materials Package Building in Los Santos !");
            return 1;
        }

        if (Arms_GetPackages(playerid) >= ARMS_PACKAGES_MAX)
        {
            SendClientMessage(playerid,COLOR_GREY,"   You can't hold any more Materials Packages !");
            return 1;
        }

        if (rest[0] == EOS)
        {
            SendClientMessage(playerid,COLOR_WHITE,"USAGE: /materials get [amount]");
            return 1;
        }

        new amount = strval(rest);

        if (amount < 1 || amount > ARMS_PACKAGES_MAX)
        {
            SendClientMessage(playerid,COLOR_GREY,"   Package Number can't be below 1 or higher than 10 !");
            return 1;
        }

        new price = amount * ARMS_PACKAGE_PRICE;

        if (Account_GetCash(playerid) < price)
        {
            format(line,sizeof(line),"   You can't afford the $%d !",price);
            SendClientMessage(playerid,COLOR_GREY,line);
            return 1;
        }

        format(line,sizeof(line),"* You bought %d Materials Packages for $%d.",amount,price);
        SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
        Account_SetCash(playerid,Account_GetCash(playerid) - price);
        Arms_SetPackages(playerid,amount);
    }
    else if (!strcmp(name,"deliver",true))
    {
        if (!Arms_IsAtFactory(playerid))
        {
            SendClientMessage(playerid,COLOR_GREY,"   You are not at the Materials Factory in San Fierro !");
            return 1;
        }

        new packages = Arms_GetPackages(playerid);

        if (packages <= 0)
        {
            SendClientMessage(playerid,COLOR_GREY,"   You don't have any Materials Packages !");
            return 1;
        }

        new payout = ARMS_PACKAGE_MATS * packages;
        format(line,sizeof(line),"* The Factory gave you %d Materials for your %d Materials Packages.",payout,packages);
        SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
        Arms_SetMats(playerid,Arms_GetMats(playerid) + payout);
        Arms_SetPackages(playerid,0);
    }
    else
    {
        SendClientMessage(playerid,COLOR_GREY,"   Invalid Materials Name !");
    }

    return 1;
}

CMD:sellgun(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Jobs_Is(playerid,JOB_ARMS))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not an Arms Dealer !");
        return 1;
    }

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /sellgun [playerid/PartOfName] [weaponname]");
        SendClientMessage(playerid,COLOR_GREY,"Weapons: flowers(25) sdpistol(100) eagle(150) mp5(200) shotgun(200)");
        SendClientMessage(playerid,COLOR_GREY,"Weapons: ak47(600) m4(600) rifle (600)");
        return 1;
    }

    new line[JOBS_LINE_LEN];

    if (!Util_IsValidPlayer(targetid))
    {
        new typed[MAX_PLAYER_NAME + 1];
        Util_FirstWord(params,typed);
        format(line,sizeof(line),"   %s is not an active player.",typed);
        SendClientMessage(playerid,COLOR_GRAD1,line);
        return 1;
    }

    new weaponName[16];
    sscanf(params,"{u}S()[16]",weaponName);

    if (weaponName[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GREEN,"________________________________________________");
        SendClientMessage(playerid,COLOR_WHITE,"*** Sell Guns ***");
        SendClientMessage(playerid,COLOR_GREY,"USAGE: /sellgun [playerid/PartOfName] [weaponname]");
        SendClientMessage(playerid,COLOR_GREY,"Weapons: flowers(25) sdpistol(100) eagle(150) mp5(200) shotgun(200)");
        SendClientMessage(playerid,COLOR_GREY,"Weapons: ak47(600) m4(600) rifle(600)");
        SendClientMessage(playerid,COLOR_GREEN,"________________________________________________");
        return 1;
    }

    new weapon = Arms_FindWeapon(weaponName);

    if (weapon == -1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Invalid Weapon name!");
        return 1;
    }

    if (Arms_GetMats(playerid) < Arms_GetWeaponNeeds(weapon))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Not enough Materials for that Weapon!");
        return 1;
    }

    new weaponId = Arms_GetWeaponId(weapon), ammo = Arms_GetWeaponAmmo(weapon), price = Arms_GetWeaponPrice(weapon);

    if (!Util_IsNear(playerid,targetid,ARMS_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   You're too far away.");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   You can not sell Guns to yourself!");
        return 1;
    }

    Weapons_SetStored(targetid,Arms_GetWeaponSlot(weapon),weaponId,ammo);

    new perk = Progress_GetPerk(playerid,PROGRESS_PERK_MISER);

    if (perk > 0)
    {
        price -= (price / 100) * (2 * perk);
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"   You have given %s, a %s with %d ammo, for %d Materials.",targetName,weaponName,ammo,price);
    PlayerPlaySound(playerid,ARMS_SOUND_DONE,0.0,0.0,0.0);
    SendClientMessage(playerid,COLOR_GRAD1,line);
    format(line,sizeof(line),"   You have received a %s with %d ammo from %s.",weaponName,ammo,name);
    SendClientMessage(targetid,COLOR_GRAD1,line);
    PlayerPlaySound(targetid,ARMS_SOUND_DONE,0.0,0.0,0.0);
    format(line,sizeof(line),"* %s created a Gun from Materials, and hands it to %s.",name,targetName);
    Chat_ProxDetector(30.0,playerid,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
    GivePlayerWeapon(targetid,WEAPON:weaponId,ammo);
    Arms_SetMats(playerid,Arms_GetMats(playerid) - price);
    return 1;
}
