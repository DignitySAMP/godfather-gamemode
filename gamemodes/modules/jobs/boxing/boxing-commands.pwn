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
static const Float:s_BoxingGymPos[3] = {765.9343, 0.2761, 1000.7173};

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
CMD<ADMIN_LEVEL_MANAGER>:setchamp(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /setchamp [playerid/PartOfName]");
        return 1;
    }

    if (!Util_IsValidPlayer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(targetid,name,sizeof(name));
    Boxing_SetTitle(name,Boxing_GetWins(targetid),Boxing_GetLoses(targetid));
    format(line,sizeof(line),"* You have made %s the new Boxing Champion.",name);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    return 1;
}

CMD:boxstats(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!Jobs_Is(playerid,JOB_BOXER))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Boxer !");
        return 1;
    }

    new title[20], nickname[20], skill = Progress_GetSkill(playerid,PROGRESS_SKILL_BOX);

    if (skill <= 50)
    {
        strcopy(title,"Beginner");
    }
    else if (skill >= 51 && skill <= 200)
    {
        strcopy(title,"Amateur");
    }
    else
    {
        strcopy(title,"Professional");
    }

    new wins = Boxing_GetWins(playerid), loses = Boxing_GetLoses(playerid);

    if (wins > 0 && loses == 0)
    {
        strcopy(nickname,"Undefeated");
    }
    else if (wins <= 10)
    {
        strcopy(nickname,"Newcomer");
    }
    else if (wins <= 20)
    {
        strcopy(nickname,"Touchy Fist");
    }
    else if (wins <= 30)
    {
        strcopy(nickname,"Nut Cracker");
    }
    else if (wins <= 40)
    {
        strcopy(nickname,"Tommygun");
    }
    else if (wins <= 50)
    {
        strcopy(nickname,"Skull Breaker");
    }
    else if (wins <= 60)
    {
        strcopy(nickname,"Light Speed");
    }
    else if (wins <= 70)
    {
        strcopy(nickname,"Unbroken Warrior");
    }
    else
    {
        strcopy(nickname,"Italian Stallion");
    }

    new champion[BOXING_NAME_LEN], line[JOBS_LINE_LEN];
    Boxing_GetTitleName(champion);

    SendClientMessage(playerid,COLOR_WHITE,"|__________________ Boxing Records __________________|");
    format(line,sizeof(line),"| Current Champion: %s, with [%d] Winnings and [%d] Losses.",champion,Boxing_GetTitleWins(),Boxing_GetTitleLoses());
    SendClientMessage(playerid,COLOR_GREY,line);
    format(line,sizeof(line),"| Current Title: %s.",title);
    SendClientMessage(playerid,COLOR_GREY,line);
    format(line,sizeof(line),"| Current NickName: %s.",nickname);
    SendClientMessage(playerid,COLOR_GREY,line);
    format(line,sizeof(line),"| Total Wins: %d.",wins);
    SendClientMessage(playerid,COLOR_GREY,line);
    format(line,sizeof(line),"| Total Losses: %d.",loses);
    SendClientMessage(playerid,COLOR_GREY,line);
    SendClientMessage(playerid,COLOR_WHITE,"|____________________________________________________|");
    return 1;
}

CMD:fight(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Jobs_Is(playerid,JOB_BOXER))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Boxer !");
        return 1;
    }

    if (Boxing_IsRingBusy())
    {
        SendClientMessage(playerid,COLOR_GREY,"   There is already a Fight going on, wait for it to Finish !");
        return 1;
    }

    if (Boxing_IsFighting(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are already Fighting !");
        return 1;
    }

    if (!Property_IsNear(playerid,BOXING_GYM_RADIUS,s_BoxingGymPos[0],s_BoxingGymPos[1],s_BoxingGymPos[2]))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not at the Grove Street Gym !");
        return 1;
    }

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /fight [Playerid/PartOfName]");
        return 1;
    }

    if (!Util_IsValidPlayer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,BOXING_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"You cannot Box with yourself!");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You offered a Boxing Challenge to %s.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* Boxer %s wants to Fight with you (type /accept boxing) to accept.",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    Boxing_SetOffer(targetid,playerid);
    return 1;
}
