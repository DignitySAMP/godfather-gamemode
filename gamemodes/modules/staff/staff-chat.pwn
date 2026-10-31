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
stock Staff_SendEnemies(colour,const text[])
{
    foreach (new i : Player)
    {
        if (!IsPlayerNPC(i) && Factions_GetTeam(i) >= 3)
        {
            SendClientMessage(i,colour,text);
        }
    }
}

stock Staff_BeepEnemies()
{
    foreach (new i : Player)
    {
        if (!IsPlayerNPC(i) && Factions_GetTeam(i) >= 3 && Account_HasSpawned(i))
        {
            Phone_Beep(i);
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
CMD:check(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Staff_HasLevel(playerid,ADMIN_LEVEL_TRIAL))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   You are not an admin");
        return 1;
    }

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /check [playerid/PartOfName]");
        return 1;
    }

    new targetid = Staff_FindPlayer(token);

    if (!Staff_IsTarget(targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   No Such Player");
        return 1;
    }

    Stats_Show(playerid,targetid);
    return 1;
}

CMD:mole(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Staff_HasLevel(playerid,ADMIN_LEVEL_MANAGER))
    {
        return 0;
    }

    new result[STAFF_REASON_LEN];

    if (Util_ReadRest(params,0,result) == 0)
    {
        return 1;
    }

    new line[STAFF_LINE_LEN];
    format(line,sizeof(line),"SMS: %s, Sender: MOLE (555)",result);

    if (Factions_GetTeam(playerid) < 3)
    {
        SendClientMessage(playerid,COLOR_YELLOW,line);
    }

    Staff_SendEnemies(COLOR_YELLOW,line);
    Staff_BeepEnemies();
    Log_Info("staff","MOLE: %s",result);
    return 1;
}

CMD:hq(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Staff_HasLevel(playerid,ADMIN_LEVEL_MANAGER))
    {
        return 0;
    }

    new result[STAFF_REASON_LEN];

    if (Util_ReadRest(params,0,result) == 0)
    {
        return 1;
    }

    new line[STAFF_LINE_LEN];
    format(line,sizeof(line),"HQ: %s, over",result);

    if (Factions_GetTeam(playerid) != 2)
    {
        SendClientMessage(playerid,COLOR_DBLUE,line);
    }

    Phone_BeepTeam(2,COLOR_DBLUE,line);
    Log_Info("staff","HQ: %s",result);
    return 1;
}

CMD:bigears(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!Staff_HasLevel(playerid,ADMIN_LEVEL_MOD))
    {
        return 0;
    }

    if (!Chat_HasBigEar(playerid))
    {
        Chat_SetBigEar(playerid,true);
        SendClientMessage(playerid,COLOR_GRAD2,"   Your Ears Have Grown");
    }
    else
    {
        Chat_SetBigEar(playerid,false);
        SendClientMessage(playerid,COLOR_GRAD2,"   Your Ears Have Shrank");
    }

    return 1;
}

CMD:admin(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new result[STAFF_REASON_LEN];

    if (Util_ReadRest(params,0,result) == 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/a)dmin [admin chat]");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], line[STAFF_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"*%d Admin %s: %s",Account_GetAdminLevel(playerid),name,result);

    if (Staff_HasLevel(playerid,ADMIN_LEVEL_TRIAL))
    {
        Staff_SendAdmins(COLOR_YELLOW,line);
    }

    return 1;
}

ALT:a=CMD:admin;

CMD:admins(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_GRAD1,"Admins Online:");

    foreach (new i : Player)
    {
        new level = Account_GetAdminLevel(i);

        if (!IsPlayerNPC(i) && level >= ADMIN_LEVEL_TRIAL && level < ADMIN_LEVEL_OWNER)
        {
            new name[MAX_PLAYER_NAME + 1], line[STAFF_LINE_LEN];
            GetPlayerName(i,name,sizeof(name));
            format(line,sizeof(line),"Admin: %s",name);
            SendClientMessage(playerid,COLOR_GRAD2,line);
        }
    }

    return 1;
}

CMD:report(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new result[STAFF_REASON_LEN];

    if (Util_ReadRest(params,0,result) == 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /report [text]");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], line[STAFF_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"Report from %s: %s",name,result);
    Staff_SendAdmins(COLOR_YELLOW,line);
    SendClientMessage(playerid,COLOR_YELLOW,"Your Report Message was sent to the Admins.");
    return 1;
}
