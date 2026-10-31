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
static bool:s_ChatOocEnabled[MAX_PLAYERS];
static bool:s_ChatNewsEnabled[MAX_PLAYERS];
static bool:s_ChatFamilyEnabled[MAX_PLAYERS];
static bool:s_ChatWhisperEnabled[MAX_PLAYERS];
static bool:s_ChatGlobalOocEnabled = true;

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
stock Chat_ResetChannels(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return;
    }

    s_ChatOocEnabled[playerid] = true;
    s_ChatNewsEnabled[playerid] = true;
    s_ChatFamilyEnabled[playerid] = true;
    s_ChatWhisperEnabled[playerid] = true;
}

stock bool:Chat_IsOocEnabled(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_ChatOocEnabled[playerid];
}

stock Chat_SetOocEnabled(playerid,bool:isEnabled)
{
    if (playerid >= 0 && playerid < MAX_PLAYERS)
    {
        s_ChatOocEnabled[playerid] = isEnabled;
    }
}

stock bool:Chat_IsNewsEnabled(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_ChatNewsEnabled[playerid];
}

stock Chat_SetNewsEnabled(playerid,bool:isEnabled)
{
    if (playerid >= 0 && playerid < MAX_PLAYERS)
    {
        s_ChatNewsEnabled[playerid] = isEnabled;
    }
}

stock bool:Chat_IsFamilyEnabled(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_ChatFamilyEnabled[playerid];
}

stock Chat_SetFamilyEnabled(playerid,bool:isEnabled)
{
    if (playerid >= 0 && playerid < MAX_PLAYERS)
    {
        s_ChatFamilyEnabled[playerid] = isEnabled;
    }
}

stock bool:Chat_IsWhisperEnabled(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_ChatWhisperEnabled[playerid];
}

stock Chat_SetWhisperEnabled(playerid,bool:isEnabled)
{
    if (playerid >= 0 && playerid < MAX_PLAYERS)
    {
        s_ChatWhisperEnabled[playerid] = isEnabled;
    }
}

stock bool:Chat_IsGlobalOocEnabled()
{
    return s_ChatGlobalOocEnabled;
}

stock Chat_SetGlobalOocEnabled(bool:isEnabled)
{
    s_ChatGlobalOocEnabled = isEnabled;
}

stock Chat_SendOoc(colour,const message[])
{
    foreach(new targetid : Player)
    {
        if (s_ChatOocEnabled[targetid])
        {
            SendClientMessage(targetid,colour,message);
        }
    }
}

/**
 *     __                            __
 *    |  \                          |  |
 *    | $$____    ______    ______  | $$   __   _______
 *    | $$    \  /      \  /      \ | $$  /  \ /       |
 *    | $$$$$$$\|  $$$$$$\|  $$$$$$\| $$_/  $$|  $$$$$$$
 *    | $$  | $$| $$  | $$| $$  | $$| $$   $$  \$$    |
 *    | $$  | $$| $$__/ $$| $$__/ $$| $$$$$$\  _\$$$$$$|
 *    | $$  | $$ \$$    $$ \$$    $$| $$  \$$\|       $$
 *     \$$   \$$  \$$$$$$   \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
#include <pp-hooks>

hook OnPlayerConnect(playerid)
{
    Chat_ResetChannels(playerid);
}

hook Account_OnRegistrationStart(playerid)
{
    Chat_SetOocEnabled(playerid,false);
    Chat_SetNewsEnabled(playerid,false);
    Chat_SetFamilyEnabled(playerid,false);
}
