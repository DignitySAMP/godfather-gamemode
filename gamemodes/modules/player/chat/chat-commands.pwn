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
#define CHAT_TEXT_LEN (64)
#define CHAT_LINE_LEN (160)
#define CHAT_ME_RANGE (30.0)
#define CHAT_LOCAL_RANGE (20.0)
#define CHAT_CLOSE_RANGE (3.0)
#define CHAT_SHOUT_RANGE (30.0)
#define CHAT_MUTTER_RANGE (5.0)

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
static Chat_Speak(playerid,const params[],const usage[],const pattern[],Float:range,colour1,colour2,colour3,colour4,colour5)
{
    new text[CHAT_TEXT_LEN];
    Util_ReadRest(params,0,text);

    if (text[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GRAD2,usage);
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], line[CHAT_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),pattern,name,text);
    Chat_ProxDetector(range,playerid,line,colour1,colour2,colour3,colour4,colour5);
    Log_Info("chat","%s",line);
    return 1;
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
CMD:ooc(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Chat_IsGlobalOocEnabled() && Account_GetAdminLevel(playerid) < 1)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   The OOC channel has been disabled by an Admin !");
        return 1;
    }

    if (Account_IsMuted(playerid))
    {
        SendClientMessage(playerid,TEAM_CYAN_COLOR,"   You can't speak, you have been silenced !");
        return 1;
    }

    new text[CHAT_TEXT_LEN];
    Util_ReadRest(params,0,text);

    if (text[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/o)oc [ooc chat]");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], line[CHAT_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"(( %s: %s ))",name,text);
    Chat_SendOoc(COLOR_OOC,line);
    Log_Info("chat","%s",line);
    return 1;
}

ALT:o=CMD:ooc;

CMD<ADMIN_LEVEL_ADMIN>:noooc(cmdid, playerid, params[])
{
    #pragma unused cmdid, playerid, params

    if (Chat_IsGlobalOocEnabled())
    {
        Chat_SetGlobalOocEnabled(false);
        SendClientMessageToAll(COLOR_GRAD2,"   OOC chat channel disabled by an Admin !");
        return 1;
    }

    Chat_SetGlobalOocEnabled(true);
    SendClientMessageToAll(COLOR_GRAD2,"   OOC chat channel enabled by an Admin !");
    return 1;
}

CMD:togooc(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Chat_IsOocEnabled(playerid))
    {
        Chat_SetOocEnabled(playerid,false);
        SendClientMessage(playerid,COLOR_GRAD2,"   OOC chat channel Disabled !");
        return 1;
    }

    Chat_SetOocEnabled(playerid,true);
    SendClientMessage(playerid,COLOR_GRAD2,"   OOC chat channel Enabled !");
    return 1;
}

CMD:togwhisper(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Account_GetDonateRank(playerid) <= 0 && Account_GetAdminLevel(playerid) <= 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Not an Admin / Premium Account User !");
        return 1;
    }

    if (Chat_IsWhisperEnabled(playerid))
    {
        Chat_SetWhisperEnabled(playerid,false);
        SendClientMessage(playerid,COLOR_GRAD2,"   Whisper chat channel Disabled !");
        return 1;
    }

    Chat_SetWhisperEnabled(playerid,true);
    SendClientMessage(playerid,COLOR_GRAD2,"   Whisper chat channel Enabled !");
    return 1;
}

CMD:me(cmdid, playerid, params[])
{
    #pragma unused cmdid

    return Chat_Speak(playerid,params,"USAGE: /me [action]","* %s %s",CHAT_ME_RANGE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
}

CMD:local(cmdid, playerid, params[])
{
    #pragma unused cmdid

    return Chat_Speak(playerid,params,"USAGE: (/l)ocal [local chat]","%s Says: %s",CHAT_LOCAL_RANGE,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
}

ALT:l=CMD:local;
ALT:say=CMD:local;

CMD:b(cmdid, playerid, params[])
{
    #pragma unused cmdid

    return Chat_Speak(playerid,params,"USAGE: /b [local ooc chat]","%s Says: (( %s ))",CHAT_LOCAL_RANGE,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
}

CMD:close(cmdid, playerid, params[])
{
    #pragma unused cmdid

    return Chat_Speak(playerid,params,"USAGE: /(c)lose [close chat text]","%s Says: %s",CHAT_CLOSE_RANGE,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
}

ALT:c=CMD:close;

CMD:shout(cmdid, playerid, params[])
{
    #pragma unused cmdid

    return Chat_Speak(playerid,params,"USAGE: (/s)hout [local chat]","%s Shouts: %s!!",CHAT_SHOUT_RANGE,COLOR_WHITE,COLOR_WHITE,COLOR_WHITE,COLOR_FADE1,COLOR_FADE2);
}

ALT:s=CMD:shout;

CMD:wisper(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/w)isper [playerid/PartOfName] [whisper text]");
        return 1;
    }

    new line[CHAT_LINE_LEN];

    if (targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid))
    {
        new typed[CHAT_TEXT_LEN];
        Util_FirstWord(params,typed);
        format(line,sizeof(line),"   %s is not an active player.",typed);
        SendClientMessage(playerid,COLOR_GRAD1,line);
        return 1;
    }

    if (!Chat_IsWhisperEnabled(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is blocking Whispers !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));

    if (targetid == playerid)
    {
        format(line,sizeof(line),"* %s mutters something.",name);
        Chat_ProxDetector(CHAT_MUTTER_RANGE,playerid,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
    }

    new text[CHAT_TEXT_LEN];
    Util_ReadRest(params,Util_SkipToken(params),text);

    if (text[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/w)isper [playerid/PartOfName] [whisper text]");
        return 1;
    }

    format(line,sizeof(line),"%s(ID: %d) whispers: %s",name,playerid,text);
    SendClientMessage(targetid,COLOR_YELLOW,line);
    format(line,sizeof(line),"Whisper sent to %s(ID: %d).",targetName,targetid);
    SendClientMessage(playerid,COLOR_YELLOW,line);
    return 1;
}

ALT:w=CMD:wisper;
