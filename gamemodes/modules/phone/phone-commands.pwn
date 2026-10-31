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
#define PHONE_TEXT_LEN (64)
#define PHONE_SOUND_SENT (1052)

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
static Phone_SplitParams(const params[],token[],rest[],tokenSize = sizeof(token),restSize = sizeof(rest))
{
    new at = 0, length = 0;

    while (params[at] != EOS && params[at] <= ' ')
    {
        at++;
    }

    while (params[at] > ' ' && length < tokenSize - 1)
    {
        token[length++] = params[at++];
    }

    token[length] = EOS;

    while (params[at] != EOS && params[at] <= ' ')
    {
        at++;
    }

    length = 0;

    while (params[at] != EOS && length < restSize - 1)
    {
        rest[length++] = params[at++];
    }

    rest[length] = EOS;
}

static Phone_TakeOut(playerid)
{
    new line[PHONE_LINE_LEN];
    format(line,sizeof(line),"* %s takes out a cellphone.",Util_GetPlayerName(playerid));
    Chat_ProxDetector(PHONE_PROX_RANGE,playerid,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
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
CMD:call(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new token[PHONE_WORD_LEN], rest[PHONE_TEXT_LEN];
    Phone_SplitParams(params,token,rest);

    if (token[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /call [phonenumber]");
        return 1;
    }

    if (Phone_GetNumber(playerid) == 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"  You don't have a cell phone !");
        return 1;
    }

    Phone_TakeOut(playerid);

    new number = strval(token);

    if (number == PHONE_LINE_EMERGENCY)
    {
        SendClientMessage(playerid,COLOR_WHITE,"HINT: You now use T to talk on your cellphone, type /hangup to hang up");
        SendClientMessage(playerid,COLOR_ALLDEPT,"EMERGENCY: Which Service Do You Require, Police or Paramedic?");
        Phone_SetLine(playerid,PHONE_LINE_EMERGENCY);
        return 1;
    }

    if (number == Phone_GetNumber(playerid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"  You just get a busy tone...");
        return 1;
    }

    if (Phone_GetLine(playerid) != PHONE_LINE_NONE)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"  You are already on a call...");
        return 1;
    }

    foreach (new targetid : Player)
    {
        if (IsPlayerNPC(targetid) || number == 0 || Phone_GetNumber(targetid) != number)
        {
            continue;
        }

        if (Phone_IsOffline(targetid))
        {
            SendClientMessage(playerid,COLOR_GREY,"   That players Phone is Offline !");
            return 1;
        }

        if (Phone_GetLine(targetid) == PHONE_LINE_NONE)
        {
            Phone_SetLine(playerid,targetid);
            new line[PHONE_LINE_LEN], name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
            GetPlayerName(playerid,name,sizeof(name));
            GetPlayerName(targetid,targetName,sizeof(targetName));
            format(line,sizeof(line),"Your Mobile is Ringing Type (/Pickup) CallerID: %s",name);
            SendClientMessage(targetid,COLOR_YELLOW,line);
            Phone_SetRingTone(targetid,PHONE_RING_CALL);
            format(line,sizeof(line),"* %s's phone begins to ring.",targetName);
            SendClientMessage(playerid,COLOR_WHITE,"HINT: You now use T to talk on your cellphone, type /hangup to hang up");
            Chat_ProxDetector(PHONE_PROX_RANGE,targetid,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
            Phone_SetCellTime(playerid,1);
            return 1;
        }
    }

    SendClientMessage(playerid,COLOR_GRAD2,"  You just get a Busy tone...");
    return 1;
}

CMD:txt(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new token[PHONE_WORD_LEN], text[PHONE_TEXT_LEN];
    Phone_SplitParams(params,token,text);

    if (token[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/t)ext [phonenumber] [text chat]");
        return 1;
    }

    if (Phone_GetNumber(playerid) == 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"  You don't have a cell phone...");
        return 1;
    }

    Phone_TakeOut(playerid);

    new number = strval(token);

    if (text[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/t)ext [phonenumber] [text chat]");
        return 1;
    }

    if (number == 555)
    {
        if (!strcmp(text,"yes",true))
        {
            SendClientMessage(playerid,COLOR_WHITE,"Text Message Delivered.");
            new team = Factions_GetTeam(playerid);

            if (team == TEAM_BLUE || team == TEAM_CYAN)
            {
                SendClientMessage(playerid,COLOR_YELLOW,"SMS: I have no idea what you're talking about, Sender: MOLE (555)");
                Phone_Beep(playerid);
            }

            return 1;
        }

        SendClientMessage(playerid,COLOR_YELLOW,"SMS: A simple Yes will do, Sender: MOLE (555)");
        Phone_Beep(playerid);
        return 1;
    }

    foreach (new targetid : Player)
    {
        if (IsPlayerNPC(targetid) || number == 0 || Phone_GetNumber(targetid) != number)
        {
            continue;
        }

        if (Phone_IsOffline(targetid))
        {
            SendClientMessage(playerid,COLOR_GREY,"   That players Phone is Offline !");
            return 1;
        }

        new line[PHONE_LINE_LEN], name[MAX_PLAYER_NAME + 1];
        GetPlayerName(playerid,name,sizeof(name));
        format(line,sizeof(line),"SMS: %s, Sender: %s (%d)",text,name,Phone_GetNumber(playerid));
        Phone_Beep(targetid);
        SendClientMessage(playerid,COLOR_WHITE,"Text Message Delivered");
        SendClientMessage(targetid,COLOR_YELLOW,line);
        SendClientMessage(playerid,COLOR_YELLOW,line);
        format(line,sizeof(line),"~r~$-%d",PHONE_TEXT_COST);
        Property_GameText(playerid,line,5000,1);
        Account_SetCash(playerid,Account_GetCash(playerid) - PHONE_TEXT_COST);
        Business_Earn(BUSINESS_SPECIAL_BASE + SBIZ_PHONE,PHONE_TEXT_COST);
        PlayerPlaySound(playerid,PHONE_SOUND_SENT,0.0,0.0,0.0);
        return 1;
    }

    SendClientMessage(playerid,COLOR_GRAD2,"  Message Delivery Failed...");
    return 1;
}

ALT:t=CMD:txt;
ALT:sms=CMD:txt;

CMD:pickup(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Phone_GetLine(playerid) != PHONE_LINE_NONE)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"  You are already on a call...");
        return 1;
    }

    foreach (new callerid : Player)
    {
        if (Phone_GetLine(callerid) != playerid)
        {
            continue;
        }

        new line[PHONE_LINE_LEN];
        Phone_SetLine(playerid,callerid);
        SendClientMessage(callerid,COLOR_GRAD2,"   They Picked up the call.");
        format(line,sizeof(line),"* %s answers his cellphone.",Util_GetPlayerName(playerid));
        Chat_ProxDetector(PHONE_PROX_RANGE,playerid,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
        Phone_SetRingTone(playerid,0);
    }

    return 1;
}

ALT:p=CMD:pickup;

CMD:hangup(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new caller = Phone_GetLine(playerid);

    if (Phone_IsPlayerLine(caller) && IsPlayerConnected(caller))
    {
        SendClientMessage(caller,COLOR_GRAD2,"   They hung up.");
        Phone_SetCellTime(caller,0);
        Phone_SetCellTime(playerid,0);
        SendClientMessage(playerid,COLOR_GRAD2,"   You hung up.");
        Phone_SetLine(caller,PHONE_LINE_NONE);
        Phone_SetLine(playerid,PHONE_LINE_NONE);
        Phone_SetCellTime(playerid,0);
        Phone_SetRingTone(playerid,0);
        return 1;
    }

    if (caller >= PHONE_LINE_EMERGENCY && caller <= PHONE_LINE_PARAMEDIC)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You hung up.");
        Phone_SetLine(playerid,PHONE_LINE_NONE);
        Phone_SetCellTime(playerid,0);
        Phone_SetRingTone(playerid,0);
        return 1;
    }

    SendClientMessage(playerid,COLOR_GRAD2,"   Your phone is in your pocket.");
    return 1;
}

ALT:h=CMD:hangup;

CMD:togphone(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Account_GetDonateRank(playerid) <= 0 && Account_GetAdminLevel(playerid) <= 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Not an Admin / Premium Account User !");
        return 1;
    }

    if (!Phone_IsOffline(playerid))
    {
        Phone_SetOffline(playerid,true);
        SendClientMessage(playerid,COLOR_GRAD2,"   Your Phone is Offline !");
        return 1;
    }

    Phone_SetOffline(playerid,false);
    SendClientMessage(playerid,COLOR_GRAD2,"   Your Phone is Online !");
    return 1;
}
