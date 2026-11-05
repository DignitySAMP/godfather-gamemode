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
#define COMMANDS_NAME_LEN (32)

#define COMMAND_DENIAL_TEXT_LEN (96)
#define COMMAND_REPLY_NOT_LOGGED_IN "   You haven't logged in yet !"
#define COMMAND_REPLY_NOT_AUTHORIZED "   you are not authorized to use that command!"

enum E_COMMAND_DENIAL
{
    E_COMMAND_DENIAL_LOGIN,
    E_COMMAND_DENIAL_LEVEL,
}

forward bool:Player_IsReady(playerid);
forward Account_GetAdminLevel(playerid);

enum e_COMMAND_REPLY
{
    E_COMMAND_REPLY_COLOUR,
    E_COMMAND_REPLY_TEXT[COMMAND_DENIAL_TEXT_LEN]
}

static Map:s_CommandDenials[E_COMMAND_DENIAL];
static Map:s_CommandSecrets;

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
static Command_Key(const name[],dest[COMMANDS_NAME_LEN])
{
    strcopy(dest,name,COMMANDS_NAME_LEN);

    for (new i = 0;dest[i] != EOS;i++)
    {
        dest[i] = tolower(dest[i]);
    }
}

stock Command_SetDenial(const name[],E_COMMAND_DENIAL:kind,colour,const text[])
{
    new key[COMMANDS_NAME_LEN], reply[e_COMMAND_REPLY];
    Command_Key(name,key);
    reply[E_COMMAND_REPLY_COLOUR] = colour;
    strcopy(reply[E_COMMAND_REPLY_TEXT],text,COMMAND_DENIAL_TEXT_LEN);

    if (!map_valid(s_CommandDenials[kind]))
    {
        s_CommandDenials[kind] = map_new();
    }

    map_str_remove(s_CommandDenials[kind],key);
    map_str_add_arr(s_CommandDenials[kind],key,reply);
    return true;
}

stock bool:Command_SetSecret(const name[])
{
    new key[COMMANDS_NAME_LEN];
    Command_Key(name,key);

    if (!map_valid(s_CommandSecrets))
    {
        s_CommandSecrets = map_new();
    }

    map_str_add(s_CommandSecrets,key,1);
    return true;
}

stock Command_GetFlags(cmdid)
{
    new pointing = GetPointingCommandID(cmdid);

    if (pointing != INVALID_COMMAND_ID && pointing != cmdid)
    {
        return GetCommandFlags(pointing);
    }

    return GetCommandFlags(cmdid);
}

static Command_Deny(playerid,cmdid,E_COMMAND_DENIAL:kind)
{
    new name[COMMANDS_NAME_LEN], pointing = GetPointingCommandID(cmdid);
    GetCommandName(pointing != INVALID_COMMAND_ID ? pointing : cmdid,name);

    new key[COMMANDS_NAME_LEN];
    Command_Key(name,key);

    if (map_valid(s_CommandDenials[kind]) && map_has_str_key(s_CommandDenials[kind],key))
    {
        new reply[e_COMMAND_REPLY];
        map_str_get_arr(s_CommandDenials[kind],key,reply);
        SendClientMessage(playerid,reply[E_COMMAND_REPLY_COLOUR],reply[E_COMMAND_REPLY_TEXT]);
        return;
    }

    if (kind == E_COMMAND_DENIAL_LOGIN)
    {
        SendClientMessage(playerid,COLOR_GREY,COMMAND_REPLY_NOT_LOGGED_IN);
        return;
    }

    SendClientMessage(playerid,COLOR_GRAD1,COMMAND_REPLY_NOT_AUTHORIZED);
}

stock bool:Command_Allows(playerid,cmdid)
{
    new flags = Command_GetFlags(cmdid);

    if (!(flags & CMD_FLAG_PRELOGIN) && !Player_IsReady(playerid))
    {
        Command_Deny(playerid,cmdid,E_COMMAND_DENIAL_LOGIN);
        return false;
    }

    new level = flags & CMD_FLAG_LEVEL_MASK;

    if (level > 0 && !IsPlayerAdmin(playerid) && Account_GetAdminLevel(playerid) < level)
    {
        Command_Deny(playerid,cmdid,E_COMMAND_DENIAL_LEVEL);
        return false;
    }

    return true;
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
public OnPlayerCommandReceived(cmdid, playerid, cmdtext[])
{
    if (IsPlayerNPC(playerid))
    {
        return 0;
    }

    if (cmdid == INVALID_COMMAND_ID)
    {
        return 1;
    }

    return Command_Allows(playerid, cmdid) ? 1 : 0;
}

public OnPlayerCommandPerformed(cmdid, playerid, cmdtext[], success)
{
    if (cmdid == INVALID_COMMAND_ID)
    {
        return 0;
    }

    return success;
}
