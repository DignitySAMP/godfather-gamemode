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
#define PHONE_WORD_LEN (32)

forward Phone_ChatCall(playerid,const text[]);

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
static Phone_Say(playerid,colour,const text[])
{
    SendClientMessage(playerid,colour,text);
}

static Phone_EndEmergency(playerid)
{
    Phone_Say(playerid,COLOR_GRAD2,"   They Hung Up...");
    Phone_SetLine(playerid,PHONE_LINE_NONE);
}

stock Phone_DropLine(playerid)
{
    new caller = Phone_GetLine(playerid);

    if (caller == PHONE_LINE_NONE)
    {
        return;
    }

    if (caller < PHONE_LINE_NONE && Phone_IsPlayerLine(caller))
    {
        SendClientMessage(caller,COLOR_GRAD2,"   The line just went dead....");
        Phone_SetCellTime(caller,0);
        Phone_SetCellTime(playerid,0);
        Phone_SetLine(caller,PHONE_LINE_NONE);
    }

    Phone_SetLine(playerid,PHONE_LINE_NONE);
    Phone_SetCellTime(playerid,0);
}

static Phone_ReleasePartners(leaving)
{
    foreach (new playerid : Player)
    {
        if (playerid != leaving && Phone_GetLine(playerid) == leaving)
        {
            SendClientMessage(playerid,COLOR_GRAD2,"   The line just went dead....");
            Phone_SetLine(playerid,PHONE_LINE_NONE);
            Phone_SetCellTime(playerid,0);
        }
    }
}

static Phone_ReportParamedic(playerid,const text[])
{
    new word[PHONE_WORD_LEN], name[MAX_PLAYER_NAME + 1], line[PHONE_LINE_LEN];
    Util_FirstWord(text,word);

    if (word[0] == EOS)
    {
        Phone_Say(playerid,TEAM_CYAN_COLOR,"Dispatch: Sorry I don't understand?");
        return;
    }

    GetPlayerName(playerid,name,sizeof(name));
    Phone_Say(playerid,TEAM_CYAN_COLOR,"Dispatch: We have alerted all units in the area.");
    Phone_Say(playerid,TEAM_CYAN_COLOR,"Thank you for reporting this incident");
    format(line,sizeof(line),"Dispatch: All Units IA: Caller: %s",name);
    Phone_BeepTeam(TEAM_CYAN,TEAM_CYAN_COLOR,line);
    format(line,sizeof(line),"Dispatch: Incident: %s",text);
    Factions_SendTeam(TEAM_CYAN,TEAM_CYAN_COLOR,line);
    Phone_EndEmergency(playerid);
}

static Phone_ReportPoliceName(playerid,const text[])
{
    new word[PHONE_WORD_LEN], name[MAX_PLAYER_NAME + 1], line[PHONE_LINE_LEN], crime[LAW_CRIME_LEN];
    Util_FirstWord(text,word);

    if (word[0] == EOS)
    {
        Phone_Say(playerid,COLOR_ALLDEPT,"EMERGENCY: Sorry I don't understand?");
        return;
    }

    if (!strcmp(word,"no",true))
    {
        GetPlayerName(playerid,name,sizeof(name));
        Law_GetCrimeText(playerid,LAW_CRIME_REPORT,crime);
        Phone_Say(playerid,COLOR_DBLUE,"Police HQ: We have alerted all units in the area.");
        Phone_Say(playerid,COLOR_DBLUE,"Thank you for reporting this crime");
        format(line,sizeof(line),"HQ: All Units APB: Reporter: %s",name);
        Families_SendFactionMessage(FACTION_POLICE,COLOR_DBLUE,line);
        format(line,sizeof(line),"HQ: Crime: %s, Suspect: Unknown",crime);
        Families_SendFactionMessage(FACTION_POLICE,COLOR_DBLUE,line);
        Phone_EndEmergency(playerid);
        return;
    }

    new badguy = INVALID_PLAYER_ID;

    if (sscanf(word,"u",badguy) || badguy == INVALID_PLAYER_ID || !IsPlayerConnected(badguy))
    {
        format(line,sizeof(line),"Police HQ: I have no Information on %s, are you sure that's the right name?",word);
        Phone_Say(playerid,COLOR_DBLUE,line);
        return;
    }

    new team = Factions_GetTeam(badguy);

    if (team == TEAM_BLUE || team == TEAM_CYAN)
    {
        Phone_Say(playerid,COLOR_DBLUE,"Police HQ: You will have to contact internal affairs. This is an emergency line");
        Phone_EndEmergency(playerid);
        return;
    }

    if (Law_GetWantedPoints(badguy) > 0)
    {
        Phone_Say(playerid,COLOR_DBLUE,"Police HQ: Units are already assigned to that case");
        Phone_Say(playerid,COLOR_DBLUE,"Thank you for reporting this crime");
        Phone_EndEmergency(playerid);
        return;
    }

    if (badguy == playerid)
    {
        Phone_Say(playerid,COLOR_DBLUE,"Police HQ: Don't Fool Around, This is an emergency line.");
        Phone_EndEmergency(playerid);
        return;
    }

    Law_GetCrimeText(playerid,LAW_CRIME_REPORT,crime);
    Phone_Say(playerid,COLOR_DBLUE,"Police HQ: We have alerted all units in the area.");
    Phone_Say(playerid,COLOR_DBLUE,"Thank you for reporting this crime");
    Law_AddCrime(badguy,2,playerid,crime);
    Phone_EndEmergency(playerid);
}

static Phone_ReportPoliceCrime(playerid,const text[])
{
    new word[PHONE_WORD_LEN];
    Util_FirstWord(text,word);

    if (word[0] == EOS)
    {
        Phone_Say(playerid,COLOR_ALLDEPT,"EMERGENCY: Sorry I don't understand?");
        return;
    }

    Law_SetCrimeText(playerid,LAW_CRIME_REPORT,text);
    Phone_Say(playerid,COLOR_DBLUE,"Police HQ: If you know the assailant's name or part of it say it now or just say no.");
    Phone_SetLine(playerid,PHONE_LINE_POLICE_NAME);
}

static Phone_ChooseService(playerid,const text[])
{
    new word[PHONE_WORD_LEN];
    Util_FirstWord(text,word);

    if (word[0] == EOS)
    {
        Phone_Say(playerid,COLOR_ALLDEPT,"EMERGENCY: Sorry I don't understand, police or paramedic?");
    }
    else if (!strcmp(word,"police",true))
    {
        Phone_Say(playerid,COLOR_ALLDEPT,"EMERGENCY: I am patching you to  Police HQ, please hold.");
        Phone_SetLine(playerid,PHONE_LINE_POLICE_CRIME);
        Phone_Say(playerid,COLOR_DBLUE,"Police HQ: Please give me a short description of the crime.");
    }
    else if (!strcmp(word,"paramedic",true))
    {
        Phone_Say(playerid,COLOR_ALLDEPT,"EMERGENCY: I am patching you to  Paramedic HQ, please hold.");
        Phone_SetLine(playerid,PHONE_LINE_PARAMEDIC);
        Phone_Say(playerid,TEAM_CYAN_COLOR,"Dispatch: Please give me a short description of the Incident.");
    }
    else
    {
        Phone_Say(playerid,COLOR_ALLDEPT,"EMERGENCY: Sorry I don't understand, police or paramedic?");
    }
}

static Phone_StepCall(playerid)
{
    new cellTime = Phone_GetCellTime(playerid);

    if (cellTime > 0)
    {
        if (cellTime == PHONE_CHARGE_TIME)
        {
            cellTime = 1;

            if (Phone_GetPartnerLine(playerid) == playerid)
            {
                Phone_SetCallCost(playerid,Phone_GetCallCost(playerid) + PHONE_CALL_COST);
            }
        }

        cellTime++;
        Phone_SetCellTime(playerid,cellTime);

        if (Phone_GetPartnerLine(playerid) == PHONE_LINE_NONE && cellTime == PHONE_RING_ANSWER_TIME)
        {
            new callee = Phone_GetLine(playerid);

            if (Phone_IsPlayerLine(callee) && IsPlayerConnected(callee))
            {
                new called[MAX_PLAYER_NAME + 1], line[PHONE_LINE_LEN];
                GetPlayerName(callee,called,sizeof(called));
                format(line,sizeof(line),"* %s's phone rings.",called);
                Phone_SetRingTone(callee,PHONE_RING_CALL);
                Chat_ProxDetector(PHONE_PROX_RANGE,callee,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
            }
        }
    }

    new cost = Phone_GetCallCost(playerid);

    if (Phone_GetCellTime(playerid) == 0 && cost > 0)
    {
        new line[48];
        format(line,sizeof(line),"~w~The call cost~n~~r~$%d",cost);
        Account_SetCash(playerid,Account_GetCash(playerid) - cost);
        Business_Earn(BUSINESS_SPECIAL_BASE + SBIZ_PHONE,cost);
        Property_GameText(playerid,line,5000,1);
        Phone_SetCallCost(playerid,0);
    }
}

stock Phone_Tick(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    Phone_StepRing(playerid);
    Phone_StepCall(playerid);
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
public Phone_ChatCall(playerid,const text[])
{
    new line = Phone_GetLine(playerid);

    if (line == PHONE_LINE_NONE)
    {
        return 0;
    }

    new name[MAX_PLAYER_NAME + 1], speech[PHONE_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(speech,sizeof(speech),"%s Says (cellphone): %s",name,text);
    Chat_ProxDetector(PHONE_SPEECH_RANGE,playerid,speech,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);

    switch (line)
    {
        case PHONE_LINE_PARAMEDIC:
        {
            Phone_ReportParamedic(playerid,text);
        }
        case PHONE_LINE_POLICE_NAME:
        {
            Phone_ReportPoliceName(playerid,text);
        }
        case PHONE_LINE_POLICE_CRIME:
        {
            Phone_ReportPoliceCrime(playerid,text);
        }
        case PHONE_LINE_EMERGENCY:
        {
            Phone_ChooseService(playerid,text);
        }
        default:
        {
            if (Phone_IsPlayerLine(line) && IsPlayerConnected(line))
            {
                if (Phone_GetLine(line) == playerid)
                {
                    SendClientMessage(line,COLOR_YELLOW,speech);
                }
            }
            else
            {
                Phone_Say(playerid,COLOR_YELLOW,"There's nobody there");
            }
        }
    }

    return 1;
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

hook Tick_OnPlayerSecond(playerid)
{
    if (Phone_IsTickEnabled())
    {
        Phone_Tick(playerid);
    }
}

hook OnPlayerDeath(playerid,killerid,WEAPON:reason)
{
    Phone_DropLine(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Phone_ReleasePartners(playerid);
}

hook Account_OnLogout(playerid,accountid)
{
    Phone_ReleasePartners(playerid);
    Phone_SetLine(playerid,PHONE_LINE_NONE);
    Phone_SetCellTime(playerid,0);
}
