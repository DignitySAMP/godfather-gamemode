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

#define COMMAND_SECRET_MAX (8)
#define COMMAND_DENIAL_MAX (96)
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

static s_CommandDenialName[COMMAND_DENIAL_MAX][COMMANDS_NAME_LEN];
static E_COMMAND_DENIAL:s_CommandDenialKind[COMMAND_DENIAL_MAX];
static s_CommandDenialColour[COMMAND_DENIAL_MAX];
static s_CommandDenialText[COMMAND_DENIAL_MAX][COMMAND_DENIAL_TEXT_LEN];
static s_CommandDenialCount;
static s_CommandSecretName[COMMAND_SECRET_MAX][COMMANDS_NAME_LEN];
static s_CommandSecretCount;

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
stock Command_SetDenial(const name[],E_COMMAND_DENIAL:kind,colour,const text[])
{
    for (new i = 0;i < s_CommandDenialCount;i++)
    {
        if (s_CommandDenialKind[i] == kind && !strcmp(s_CommandDenialName[i],name,true))
        {
            s_CommandDenialColour[i] = colour;
            strcopy(s_CommandDenialText[i],text,COMMAND_DENIAL_TEXT_LEN);
            return true;
        }
    }

    if (s_CommandDenialCount >= COMMAND_DENIAL_MAX)
    {
        Log_Error("commands","denial table full - '%s' keeps the default text",name);
        return false;
    }

    strcopy(s_CommandDenialName[s_CommandDenialCount],name,COMMANDS_NAME_LEN);
    s_CommandDenialKind[s_CommandDenialCount] = kind;
    s_CommandDenialColour[s_CommandDenialCount] = colour;
    strcopy(s_CommandDenialText[s_CommandDenialCount],text,COMMAND_DENIAL_TEXT_LEN);
    s_CommandDenialCount++;
    return true;
}

stock bool:Command_SetSecret(const name[])
{
    if (s_CommandSecretCount >= COMMAND_SECRET_MAX)
    {
        Log_Error("commands","secret table full - '%s' would be logged in clear",name);
        return false;
    }

    strcopy(s_CommandSecretName[s_CommandSecretCount],name,COMMANDS_NAME_LEN);
    s_CommandSecretCount++;
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

    for (new i = 0;i < s_CommandDenialCount;i++)
    {
        if (s_CommandDenialKind[i] == kind && !strcmp(s_CommandDenialName[i],name,true))
        {
            SendClientMessage(playerid,s_CommandDenialColour[i],s_CommandDenialText[i]);
            return;
        }
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
