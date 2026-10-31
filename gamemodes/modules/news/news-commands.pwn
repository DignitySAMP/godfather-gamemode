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
#define NEWS_REPORT_TEXT_LEN (64)
#define NEWS_AD_COST (25)
#define NEWS_AD_DELAY_MS (60000)
#define NEWS_AD_BUSINESS (BUSINESS_SPECIAL_BASE + 7)
#define NEWS_SKILL_LEVEL_2 (50)
#define NEWS_SKILL_LEVEL_3 (100)
#define NEWS_SKILL_LEVEL_4 (200)
#define NEWS_SKILL_LEVEL_5 (400)
#define NEWS_RANK_DELETE (4)

static bool:s_NewsAdsOn = true;

forward News_AddsOn();

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

static bool:News_IsReporter(playerid)
{
    return Factions_IsIn(playerid,FACTION_NEWS);
}

static News_AnnounceSkill(playerid,skill)
{
    switch (skill)
    {
        case NEWS_SKILL_LEVEL_2:
        {
            SendClientMessage(playerid,COLOR_YELLOW,"* Your News Reporter Skill is now Level 2, soon you are able to Fly the News Chopper and talk Live.");
        }
        case NEWS_SKILL_LEVEL_3:
        {
            SendClientMessage(playerid,COLOR_YELLOW,"* Your News Reporter Skill is now Level 3, soon you are able to Fly the News Chopper and talk Live.");
        }
        case NEWS_SKILL_LEVEL_4:
        {
            SendClientMessage(playerid,COLOR_YELLOW,"* Your News Reporter Skill is now Level 4, you can fly the News Chopper now.");
        }
        case NEWS_SKILL_LEVEL_5:
        {
            SendClientMessage(playerid,COLOR_YELLOW,"* Your News Reporter Skill is now Level 5, you can now talk Live with any person you want.");
        }
    }
}

static bool:News_IsAtBuilding(playerid)
{
    return Property_IsNear(playerid,NEWS_BUILDING_RADIUS,NEWS_BUILDING_X,NEWS_BUILDING_Y,NEWS_BUILDING_Z);
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
CMD:advertise(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new text[NEWS_REPORT_TEXT_LEN];
    Util_ReadRest(params,0,text);

    if (text[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/ad)vertise [advert text]");
        return 1;
    }

    new isAdmin = Account_GetAdminLevel(playerid) >= 1;

    if (!s_NewsAdsOn && !isAdmin)
    {
        new line[NEWS_TEXT_LEN];
        format(line,sizeof(line),"   Please try again later %d seconds between Advertisements !",NEWS_AD_DELAY_MS / 1000);
        SendClientMessage(playerid,COLOR_GRAD2,line);
        return 1;
    }

    new line[NEWS_TEXT_LEN], length = strlen(text), payout = length * NEWS_AD_COST;

    if (Account_GetCash(playerid) < payout)
    {
        format(line,sizeof(line),"* You used %d characters which cost $%d, you don't have enough.",length,payout);
        SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
        return 1;
    }

    Account_SetCash(playerid,Account_GetCash(playerid) - payout);
    Business_Earn(NEWS_AD_BUSINESS,payout);
    format(line,sizeof(line),"Advertisement: %s, Contact: %s Ph: %d",text,Util_GetPlayerName(playerid),Phone_GetNumber(playerid));
    News_Send(TEAM_GROVE_COLOR,line);
    format(line,sizeof(line),"~r~Paid $%d~n~~w~Message contained: %d Characters",payout,length);
    Property_GameText(playerid,line,5000,5);

    if (!isAdmin)
    {
        SetTimer("News_AddsOn",NEWS_AD_DELAY_MS,false);
        s_NewsAdsOn = false;
    }

    return 1;
}

ALT:ad=CMD:advertise;

CMD:tognews(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Chat_IsNewsEnabled(playerid))
    {
        Chat_SetNewsEnabled(playerid,false);
        SendClientMessage(playerid,COLOR_GRAD2,"   News chat channel Disabled !");
        return 1;
    }

    Chat_SetNewsEnabled(playerid,true);
    SendClientMessage(playerid,COLOR_GRAD2,"   News chat channel Enabled !");
    return 1;
}

CMD:news(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!News_IsReporter(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a News Reporter !");
        return 1;
    }

    if (Account_IsMuted(playerid))
    {
        SendClientMessage(playerid,TEAM_CYAN_COLOR,"You cannot speak, you have been silenced");
        return 1;
    }

    if (!(Vehicles_GetGates(GetPlayerVehicleID(playerid)) & VEHICLE_GATE_NEWS))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not in the News Van or Chopper !");
        return 1;
    }

    new text[NEWS_REPORT_TEXT_LEN];
    Util_ReadRest(params,0,text);

    if (text[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /news [newstext]");
        return 1;
    }

    new line[NEWS_TEXT_LEN];
    format(line,sizeof(line),"NR %s: %s",Util_GetPlayerName(playerid),text);
    News_Send(COLOR_NEWS,line);
    News_AnnounceSkill(playerid,Progress_AddSkill(playerid,PROGRESS_SKILL_NEWS));
    return 1;
}

CMD:live(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!News_IsReporter(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a News Reporter !");
        return 1;
    }

    if (News_IsTalkingLive(playerid))
    {
        News_EndLive(playerid);
        return 1;
    }

    if (Progress_GetSkill(playerid,PROGRESS_SKILL_NEWS) < NEWS_SKILL_LEVEL_5)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Your News Reporter Skill is too low to talk Live with people !");
        return 1;
    }

    new text[NEWS_REPORT_TEXT_LEN];
    Util_ReadRest(params,0,text);

    if (text[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /live [playerid/PartOfName]");
        return 1;
    }

    new targetid = INVALID_PLAYER_ID;

    if (sscanf(text,"u",targetid) || targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Invalid ID/Name !");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,NEWS_LIVE_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are too far away from that player !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"You cannot Talk Live with yourself!");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[NEWS_TEXT_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You offered %s to have a Live Conversation.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s offered you to have a Live Conversation, type (/accept live) to accept.",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    News_SetLiveOffer(targetid,playerid);
    return 1;
}

CMD:papers(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!News_IsReporter(playerid) && !Jobs_Is(playerid,JOB_PAPERBOY))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Paper Boy / News Reporter !");
        return 1;
    }

    if (!News_IsAtBuilding(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not at the News Reporter Building !");
        return 1;
    }

    for (new paper = 0;paper < NEWS_PAPER_COUNT;paper++)
    {
        if (News_IsPaperUsed(paper))
        {
            new line[NEWS_TEXT_LEN], title[NEWS_TITLE_LEN], maker[NEWS_MAKER_LEN];
            News_GetPaperTitle(paper,title);
            News_GetPaperMaker(paper,maker);
            format(line,sizeof(line),"|%d| Newspaper: %s, By: %s",paper + 1,title,maker);
            SendClientMessage(playerid,COLOR_WHITE,line);
        }
    }

    return 1;
}

CMD:paper(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!News_IsReporter(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a News Reporter !");
        return 1;
    }

    if (!News_IsAtBuilding(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not at the News Reporter Building !");
        return 1;
    }

    new option[16], number[16];

    if (sscanf(params,"s[16]S()[16]",option,number) || option[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /paper write [papernr] or /paper delete [papernr]");
        return 1;
    }

    if (!strcmp(option,"write",true))
    {
        if (number[0] == EOS)
        {
            SendClientMessage(playerid,COLOR_WHITE,"USAGE: /paper write [papernr]");
            return 1;
        }

        new paper = strval(number);

        if (paper < 1 || paper > NEWS_PAPER_COUNT)
        {
            SendClientMessage(playerid,COLOR_GREY,"   Paper Number can't be below 1 or above 10 !");
            return 1;
        }

        paper--;

        if (News_IsPaperUsed(paper))
        {
            SendClientMessage(playerid,COLOR_GREY,"   There is already a Newspaper on that number !");
            return 1;
        }

        SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You are producing a new Newspaper.");
        SendClientMessage(playerid,COLOR_LIGHTRED,"* Everything you type now will be added to the Newspaper, you have 7 lines available.");
        SendClientMessage(playerid,COLOR_LIGHTRED,"* Please type in the Title of your Newspaper.");
        News_BeginWriting(playerid,paper);
        return 1;
    }

    if (!strcmp(option,"delete",true))
    {
        if (Factions_GetRank(playerid) < NEWS_RANK_DELETE)
        {
            SendClientMessage(playerid,COLOR_GREY,"   You need Rank 4 in order to Delete Newspapers !");
            return 1;
        }

        if (number[0] == EOS)
        {
            SendClientMessage(playerid,COLOR_WHITE,"USAGE: /paper delete [papernr]");
            return 1;
        }

        new paper = strval(number);

        if (paper < 1 || paper > NEWS_PAPER_COUNT)
        {
            SendClientMessage(playerid,COLOR_GREY,"   Paper Number can't be below 1 or above 10 !");
            return 1;
        }

        News_ClearPaper(paper - 1);

        new line[48];
        format(line,sizeof(line),"You've deleted Newspaper %d.",paper);
        SendClientMessage(playerid,COLOR_YELLOW,line);
        return 1;
    }

    SendClientMessage(playerid,COLOR_WHITE,"USAGE: /paper write [papernr] or /paper delete [papernr]");
    return 1;
}

CMD:read(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new option[16], number[16];

    if (sscanf(params,"s[16]S()[16]",option,number) || option[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /read [name]");
        SendClientMessage(playerid,COLOR_GREY,"Available names: Paper, TestPaper");
        return 1;
    }

    if (!strcmp(option,"paper",true))
    {
        if (News_HasPaper(playerid))
        {
            News_ShowCopy(playerid,playerid);
            return 1;
        }

        SendClientMessage(playerid,COLOR_GREY,"   You don't have a Newspaper !");
        return 1;
    }

    if (!strcmp(option,"testpaper",true))
    {
        if (!News_IsReporter(playerid))
        {
            SendClientMessage(playerid,COLOR_GREY,"   You are not a News Reporter !");
            return 1;
        }

        if (number[0] == EOS)
        {
            SendClientMessage(playerid,COLOR_WHITE,"USAGE: /read testpaper [papernr]");
            return 1;
        }

        new paper = strval(number);

        if (paper < 1 || paper > NEWS_PAPER_COUNT)
        {
            SendClientMessage(playerid,COLOR_GREY,"   Paper Number can't be below 1 or above 10 !");
            return 1;
        }

        paper--;

        if (!News_IsPaperUsed(paper))
        {
            SendClientMessage(playerid,COLOR_GREY,"   There is no Newspaper written on that number !");
            return 1;
        }

        News_ShowPaper(playerid,paper);
        return 1;
    }

    SendClientMessage(playerid,COLOR_WHITE,"USAGE: /read testpaper [papernr]");
    return 1;
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
public News_AddsOn()
{
    s_NewsAdsOn = true;
    return 1;
}
