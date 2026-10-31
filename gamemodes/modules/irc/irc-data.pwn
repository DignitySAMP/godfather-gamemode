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
#define IRC_CHANNELS (10)
#define IRC_NONE (-1)
#define IRC_ADMIN_LEN (MAX_PLAYER_NAME + 1)
#define IRC_TEXT_LEN (128)
#define IRC_CHAT_LEN (64)
#define IRC_LINE_LEN (256)

enum E_IRC_CHANNEL
{
    E_IRC_ADMIN[IRC_ADMIN_LEN],
    E_IRC_MOTD[IRC_TEXT_LEN],
    E_IRC_PASSWORD[IRC_TEXT_LEN],
    E_IRC_NEED_PASS,
    E_IRC_LOCKED
}

static s_Irc[IRC_CHANNELS][E_IRC_CHANNEL];
static s_IrcChannel[MAX_PLAYERS];

forward Task:Irc_LoadChannels();
forward Irc_LoadOnBoot();

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
stock bool:Irc_IsValidChannel(channel)
{
    return channel >= 0 && channel < IRC_CHANNELS;
}

stock Irc_GetChannel(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return IRC_NONE;
    }

    return s_IrcChannel[playerid];
}

stock Irc_GetAdmin(channel,dest[],size = sizeof(dest))
{
    if (!Irc_IsValidChannel(channel))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_Irc[channel][E_IRC_ADMIN],size);
}

stock bool:Irc_NeedsPassword(channel)
{
    return Irc_IsValidChannel(channel) && s_Irc[channel][E_IRC_NEED_PASS] != 0;
}

stock bool:Irc_IsLocked(channel)
{
    return Irc_IsValidChannel(channel) && s_Irc[channel][E_IRC_LOCKED] != 0;
}

stock Irc_CountPlayers(channel)
{
    new count = 0;

    foreach (new playerid : Player)
    {
        if (!IsPlayerNPC(playerid) && s_IrcChannel[playerid] == channel)
        {
            count++;
        }
    }

    return count;
}

stock bool:Irc_IsAdminOf(channel,playerid)
{
    if (!Irc_IsValidChannel(channel) || !Util_IsValidPlayer(playerid))
    {
        return false;
    }

    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));
    return !strcmp(s_Irc[channel][E_IRC_ADMIN],name,true);
}

stock Irc_Send(channel,colour,const text[])
{
    foreach (new playerid : Player)
    {
        if (!IsPlayerNPC(playerid) && s_IrcChannel[playerid] == channel)
        {
            SendClientMessage(playerid,colour,text);
        }
    }
}

stock Irc_Save(channel)
{
    if (!Irc_IsValidChannel(channel))
    {
        return;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE irc_channels SET admin = '%e', motd = '%e', password = '%e', need_pass = %d, locked = %d WHERE channel_id = %d",s_Irc[channel][E_IRC_ADMIN],s_Irc[channel][E_IRC_MOTD],s_Irc[channel][E_IRC_PASSWORD],s_Irc[channel][E_IRC_NEED_PASS],s_Irc[channel][E_IRC_LOCKED],channel));
}

stock bool:Irc_SetPassword(channel,const password[])
{
    if (!Irc_IsValidChannel(channel))
    {
        return false;
    }

    strcopy(s_Irc[channel][E_IRC_PASSWORD],password,IRC_TEXT_LEN);
    Irc_Save(channel);
    return true;
}

stock bool:Irc_SetMotd(channel,const motd[])
{
    if (!Irc_IsValidChannel(channel))
    {
        return false;
    }

    strcopy(s_Irc[channel][E_IRC_MOTD],motd,IRC_TEXT_LEN);
    Irc_Save(channel);
    return true;
}

stock bool:Irc_SetNeedsPassword(channel,bool:needed)
{
    if (!Irc_IsValidChannel(channel))
    {
        return false;
    }

    s_Irc[channel][E_IRC_NEED_PASS] = needed ? 1 : 0;
    Irc_Save(channel);
    return true;
}

stock bool:Irc_SetLocked(channel,bool:locked)
{
    if (!Irc_IsValidChannel(channel))
    {
        return false;
    }

    s_Irc[channel][E_IRC_LOCKED] = locked ? 1 : 0;
    Irc_Save(channel);
    return true;
}

stock bool:Irc_SetAdmin(targetid,number)
{
    if (!Util_IsValidPlayer(targetid) || number < 1 || number > IRC_CHANNELS)
    {
        return false;
    }

    new channel = number - 1;
    GetPlayerName(targetid,s_Irc[channel][E_IRC_ADMIN],IRC_ADMIN_LEN);
    s_Irc[channel][E_IRC_NEED_PASS] = 0;
    s_Irc[channel][E_IRC_LOCKED] = 0;
    Irc_Save(channel);
    return true;
}

stock Irc_Leave(playerid)
{
    new channel = s_IrcChannel[playerid];

    if (channel == IRC_NONE)
    {
        return;
    }

    new name[MAX_PLAYER_NAME + 1], line[IRC_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"* %s has left the Channel.",name);
    Irc_Send(channel,COLOR_GREEN,line);
    s_IrcChannel[playerid] = IRC_NONE;
}

stock Irc_Join(playerid,channel)
{
    if (!Util_IsValidPlayer(playerid) || !Irc_IsValidChannel(channel))
    {
        return;
    }

    new name[MAX_PLAYER_NAME + 1], line[IRC_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));

    if (s_IrcChannel[playerid] != IRC_NONE)
    {
        format(line,sizeof(line),"* %s has left the Channel.",name);
        Irc_Send(s_IrcChannel[playerid],COLOR_GREEN,line);
    }

    s_IrcChannel[playerid] = channel;

    if (Irc_IsAdminOf(channel,playerid))
    {
        format(line,sizeof(line),"* You have joined IRC Channel %d as the Administrator.",channel + 1);
    }
    else if (s_Irc[channel][E_IRC_ADMIN][0] == EOS)
    {
        format(line,sizeof(line),"* You have joined IRC Channel %d.",channel + 1);
    }
    else
    {
        format(line,sizeof(line),"* You have joined IRC Channel %d, Admin: %s.",channel + 1,s_Irc[channel][E_IRC_ADMIN]);
    }

    SendClientMessage(playerid,COLOR_YELLOW,line);

    if (s_Irc[channel][E_IRC_MOTD][0] != EOS)
    {
        format(line,sizeof(line),"MOTD: %s.",s_Irc[channel][E_IRC_MOTD]);
        SendClientMessage(playerid,COLOR_YELLOW,line);
    }

    format(line,sizeof(line),"* %s has joined the Channel.",name);
    Irc_Send(channel,COLOR_GREEN,line);
}

stock Irc_JoinWithPassword(playerid,channel,const password[])
{
    if (!Util_IsValidPlayer(playerid) || !Irc_IsValidChannel(channel))
    {
        return;
    }

    if (!strcmp(s_Irc[channel][E_IRC_PASSWORD],password,true))
    {
        Irc_Join(playerid,channel);
    }
    else
    {
        SendClientMessage(playerid,COLOR_GREY,"   Wrong Channel Password !");
    }
}

stock Irc_Reset(playerid)
{
    s_IrcChannel[playerid] = IRC_NONE;
}

#pragma warning push
#pragma warning disable 204
async Task:Irc_LoadChannels()
{
    await mysql_aquery_s(g_Mysql,str_new("SELECT channel_id, admin, motd, password, need_pass, locked FROM irc_channels ORDER BY channel_id"),false);

    new rows = cache_num_rows();

    for (new i = 0;i < rows;i++)
    {
        new channel = 0;
        cache_get_value_name_int(i,"channel_id",channel);

        if (!Irc_IsValidChannel(channel))
        {
            continue;
        }

        cache_get_value_name(i,"admin",s_Irc[channel][E_IRC_ADMIN],IRC_ADMIN_LEN);
        cache_get_value_name(i,"motd",s_Irc[channel][E_IRC_MOTD],IRC_TEXT_LEN);
        cache_get_value_name(i,"password",s_Irc[channel][E_IRC_PASSWORD],IRC_TEXT_LEN);
        cache_get_value_name_int(i,"need_pass",s_Irc[channel][E_IRC_NEED_PASS]);
        cache_get_value_name_int(i,"locked",s_Irc[channel][E_IRC_LOCKED]);
    }

    return async 1;
}
#pragma warning pop

static Irc_BootTask()
{
    yield 1;

    await Irc_LoadChannels();
    Boot_LoaderDone();
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
public Irc_LoadOnBoot()
{
    Irc_BootTask();
    return 1;
}
