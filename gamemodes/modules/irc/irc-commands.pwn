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
#define IRC_TOKEN_LEN (128)

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
static bool:Irc_ReadChannel(playerid,const params[],&at,const usage[],&channel)
{
    new token[IRC_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,usage);
        return false;
    }

    channel = strval(token);

    if (channel < 1 || channel > IRC_CHANNELS)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Channel Number can't be below 1 or above 10 !");
        return false;
    }

    channel -= 1;
    return true;
}

static bool:Irc_ReadAdminChannel(playerid,const params[],&at,const usage[],&channel)
{
    if (!Irc_ReadChannel(playerid,params,at,usage,channel))
    {
        return false;
    }

    if (!Irc_IsAdminOf(channel,playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not the Admin of that Channel !");
        return false;
    }

    return true;
}

static Irc_RunJoin(playerid,const params[],&at)
{
    new channel;

    if (!Irc_ReadChannel(playerid,params,at,"USAGE: /irc join [channelnr] or /irc join [channelnr] [password]",channel))
    {
        return;
    }

    if (Irc_IsLocked(channel))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That Channel is Locked, please choose a different one !");
        return;
    }

    if (!Irc_NeedsPassword(channel))
    {
        Irc_Join(playerid,channel);
        return;
    }

    new password[IRC_TOKEN_LEN];

    if (!Util_ReadToken(params,at,password))
    {
        SendClientMessage(playerid,COLOR_WHITE,"There's a password required to join this Channel.");
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /irc join [channelnr] [password]");
        return;
    }

    Irc_JoinWithPassword(playerid,channel,password);
}

static Irc_RunStatus(playerid)
{
    new line[IRC_LINE_LEN];

    for (new channel = 0;channel < IRC_CHANNELS;channel++)
    {
        format(line,sizeof(line),"Channel %d: %d Players Connected.",channel + 1,Irc_CountPlayers(channel));
        SendClientMessage(playerid,COLOR_WHITE,line);
    }
}

static Irc_RunAdmins(playerid)
{
    new line[IRC_LINE_LEN], admin[IRC_ADMIN_LEN];

    for (new channel = 0;channel < IRC_CHANNELS;channel++)
    {
        Irc_GetAdmin(channel,admin);
        format(line,sizeof(line),"Channel %d: %s.",channel + 1,admin);
        SendClientMessage(playerid,COLOR_WHITE,line);
    }
}

static Irc_RunPassword(playerid,const params[],&at)
{
    new channel;

    if (!Irc_ReadAdminChannel(playerid,params,at,"USAGE: /irc password [channelnr] [password]",channel))
    {
        return;
    }

    new password[IRC_TOKEN_LEN];

    if (!Util_ReadToken(params,at,password))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /irc password [channelnr] [password]");
        return;
    }

    Irc_SetPassword(channel,password);

    new line[IRC_LINE_LEN];
    format(line,sizeof(line),"You've changed the IRC Channel's Password to: %s.",password);
    SendClientMessage(playerid,COLOR_YELLOW,line);
}

static Irc_RunNeedPass(playerid,const params[],&at)
{
    new channel;

    if (!Irc_ReadAdminChannel(playerid,params,at,"USAGE: /irc needpass [channelnr]",channel))
    {
        return;
    }

    if (Irc_NeedsPassword(channel))
    {
        Irc_SetNeedsPassword(channel,false);
        SendClientMessage(playerid,COLOR_YELLOW,"Players won't have to fill in a password in order to join the IRC Channel now.");
    }
    else
    {
        Irc_SetNeedsPassword(channel,true);
        SendClientMessage(playerid,COLOR_YELLOW,"Players must fill in a password in order to join the IRC Channel now.");
    }
}

static Irc_RunLock(playerid,const params[],&at)
{
    new channel;

    if (!Irc_ReadAdminChannel(playerid,params,at,"USAGE: /irc lock [channelnr]",channel))
    {
        return;
    }

    if (Irc_IsLocked(channel))
    {
        Irc_SetLocked(channel,false);
        SendClientMessage(playerid,COLOR_YELLOW,"You've unlocked the IRC Channel.");
    }
    else
    {
        Irc_SetLocked(channel,true);
        SendClientMessage(playerid,COLOR_YELLOW,"You've locked the IRC Channel.");
    }
}

static Irc_RunMotd(playerid,const params[],&at)
{
    new channel;

    if (!Irc_ReadAdminChannel(playerid,params,at,"USAGE: /irc motd [channelnr] [motdtext]",channel))
    {
        return;
    }

    new motd[IRC_CHAT_LEN];

    if (Util_ReadRest(params,at,motd) == 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /irc motd [motdtext]");
        return;
    }

    Irc_SetMotd(channel,motd);
    SendClientMessage(playerid,COLOR_YELLOW,"You've adjusted the IRC Channel's MOTD Text.");
}

static Irc_RunLeave(playerid)
{
    if (Irc_GetChannel(playerid) == IRC_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not in an IRC Channel !");
        return;
    }

    Irc_Leave(playerid);
}

static Irc_RunKick(playerid,const params[],&at)
{
    new channel = Irc_GetChannel(playerid);

    if (channel == IRC_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not in an IRC Channel !");
        return;
    }

    if (!Irc_IsAdminOf(channel,playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not the Admin of the Channel !");
        return;
    }

    new token[IRC_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /irc kick [playerid/PartOfName]");
        return;
    }

    new targetid = INVALID_PLAYER_ID;

    if (sscanf(token,"u",targetid) || targetid == INVALID_PLAYER_ID || !Util_IsValidPlayer(targetid) || IsPlayerNPC(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return;
    }

    if (Irc_GetChannel(targetid) != channel)
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not in your IRC Channel !");
        return;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[IRC_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You've kicked %s out of your IRC Channel.",targetName);
    SendClientMessage(playerid,COLOR_YELLOW,line);
    format(line,sizeof(line),"* You've been kicked out of the IRC Channel by Channel Admin: %s.",name);
    SendClientMessage(targetid,COLOR_YELLOW,line);
    format(line,sizeof(line),"* %s has left the Channel (Kicked).",targetName);
    Irc_Send(channel,COLOR_GREEN,line);
    Irc_Reset(targetid);
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
CMD:irc(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, option[IRC_TOKEN_LEN];

    if (!Util_ReadToken(params,at,option))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: (/irc join [channelnr] or /irc join [channelnr] [password])  (/irc Leave)  (/irc Admins)");
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /irc [name] [channelnr]");
        SendClientMessage(playerid,COLOR_WHITE,"Available names: MOTD, Password, NeedPass, Lock, Kick, Status");
        return 1;
    }

    if (!strcmp(option,"join",true))
    {
        Irc_RunJoin(playerid,params,at);
    }
    else if (!strcmp(option,"status",true))
    {
        Irc_RunStatus(playerid);
    }
    else if (!strcmp(option,"password",true))
    {
        Irc_RunPassword(playerid,params,at);
    }
    else if (!strcmp(option,"needpass",true))
    {
        Irc_RunNeedPass(playerid,params,at);
    }
    else if (!strcmp(option,"lock",true))
    {
        Irc_RunLock(playerid,params,at);
    }
    else if (!strcmp(option,"motd",true))
    {
        Irc_RunMotd(playerid,params,at);
    }
    else if (!strcmp(option,"leave",true))
    {
        Irc_RunLeave(playerid);
    }
    else if (!strcmp(option,"admins",true))
    {
        Irc_RunAdmins(playerid);
    }
    else if (!strcmp(option,"kick",true))
    {
        Irc_RunKick(playerid,params,at);
    }
    else
    {
        SendClientMessage(playerid,COLOR_GREY,"   Invalid IRC Channel Number ! ");
    }

    return 1;
}

CMD:i(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new channel = Irc_GetChannel(playerid);

    if (channel == IRC_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not in an IRC Channel !");
        return 1;
    }

    if (Account_IsMuted(playerid))
    {
        SendClientMessage(playerid,TEAM_CYAN_COLOR,"You cannot speak, you have been silenced");
        return 1;
    }

    new text[IRC_CHAT_LEN];

    if (Util_ReadRest(params,0,text) == 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /i [irc chat]");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], line[IRC_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"** IRC %s: %s. **",name,text);
    Irc_Send(channel,COLOR_YELLOW2,line);
    return 1;
}

CMD<ADMIN_LEVEL_DEVELOPER>:makeircadmin(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[IRC_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /makeircadmin [playerid/PartOfName] [ChannelNr]");
        return 1;
    }

    new targetid = INVALID_PLAYER_ID;

    if (sscanf(token,"u",targetid))
    {
        targetid = INVALID_PLAYER_ID;
    }

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /makeircadmin [playerid/PartOfName] [ChannelNr]");
        return 1;
    }

    new channel = strval(token);

    if (channel > IRC_CHANNELS || channel < 0)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Don't go below number 0, or above number 10!");
        return 1;
    }

    if (targetid == INVALID_PLAYER_ID || !Util_IsValidPlayer(targetid) || IsPlayerNPC(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[IRC_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"* You've made %s an IRC Admin over Channel %d.",targetName,channel);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s has made you an IRC Admin over Channel %d.",name,channel);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    Irc_SetAdmin(targetid,channel);
    return 1;
}
