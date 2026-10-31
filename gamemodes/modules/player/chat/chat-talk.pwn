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
#define CHAT_SAY_RANGE (20.0)
#define CHAT_SAY_FORMAT "%s Says: %s"

static bool:s_ChatBigEar[MAX_PLAYERS];

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
stock Chat_SetBigEar(playerid,bool:isEnabled)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return;
    }

    s_ChatBigEar[playerid] = isEnabled;
}

stock bool:Chat_HasBigEar(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_ChatBigEar[playerid];
}

stock Chat_ProxDetector(Float:radius,playerid,const message[],colour1,colour2,colour3,colour4,colour5)
{
    if (!IsPlayerConnected(playerid))
    {
        return 1;
    }

    new Float:originX, Float:originY, Float:originZ;
    GetPlayerPos(playerid,originX,originY,originZ);

    foreach(new targetid : Player)
    {
        if (s_ChatBigEar[targetid])
        {
            SendClientMessage(targetid,colour1,message);
            continue;
        }

        new Float:targetX, Float:targetY, Float:targetZ;
        GetPlayerPos(targetid,targetX,targetY,targetZ);

        new Float:deltaX = floatabs(originX - targetX), Float:deltaY = floatabs(originY - targetY), Float:deltaZ = floatabs(originZ - targetZ);

        if (deltaX < radius / 16.0 && deltaY < radius / 16.0 && deltaZ < radius / 16.0)
        {
            SendClientMessage(targetid,colour1,message);
        }
        else if (deltaX < radius / 8.0 && deltaY < radius / 8.0 && deltaZ < radius / 8.0)
        {
            SendClientMessage(targetid,colour2,message);
        }
        else if (deltaX < radius / 4.0 && deltaY < radius / 4.0 && deltaZ < radius / 4.0)
        {
            SendClientMessage(targetid,colour3,message);
        }
        else if (deltaX < radius / 2.0 && deltaY < radius / 2.0 && deltaZ < radius / 2.0)
        {
            SendClientMessage(targetid,colour4,message);
        }
        else if (deltaX < radius && deltaY < radius && deltaZ < radius)
        {
            SendClientMessage(targetid,colour5,message);
        }
    }

    return 1;
}

Chat_SayDefault(playerid,const text[])
{
    if (!Chat_IsRealChat())
    {
        return 1;
    }

    if (!Player_IsReady(playerid))
    {
        return 0;
    }

    new name[MAX_PLAYER_NAME + 1], line[256];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),CHAT_SAY_FORMAT,name,text);
    Chat_ProxDetector(CHAT_SAY_RANGE,playerid,line,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
    return 0;
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
    s_ChatBigEar[playerid] = false;
}
