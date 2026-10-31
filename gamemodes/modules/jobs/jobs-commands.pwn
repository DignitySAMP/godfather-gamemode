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
forward Jobs_AcceptJob(playerid,const params[]);

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
stock Jobs_TickContracts()
{
    foreach (new playerid : Player)
    {
        if (!Jobs_IsLoaded(playerid) || Jobs_GetJob(playerid) <= JOB_NONE)
        {
            continue;
        }

        if (Jobs_GetContractTime(playerid) < JOBS_CONTRACT_MAX)
        {
            Jobs_SetContractTime(playerid,Jobs_GetContractTime(playerid) + 1);
        }
    }
}

static Jobs_QuitFinish(playerid,const text[])
{
    SendClientMessage(playerid,COLOR_LIGHTBLUE,text);
    Jobs_SetJob(playerid,JOB_NONE);
    Account_SetChar(playerid,0);
    Jobs_SetContractTime(playerid,0);
}

static Jobs_QuitWait(playerid,needed)
{
    new line[JOBS_LINE_LEN], hours = needed - Jobs_GetContractTime(playerid);
    format(line,sizeof(line),"* You still have %d hours left to fulfill and end your Contract.",hours / 2);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
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
CMD:join(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Jobs_GetJob(playerid) != JOB_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You already have a Job, use /quitjob first !");
        return 1;
    }

    new team = Factions_GetTeam(playerid);

    if (team == TEAM_CYAN || team == TEAM_BLUE || team == TEAM_ORANGE || team == TEAM_ADMIN)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You must be a Civilian (Not Wanted) or a Family Member to get a Job !");
        return 1;
    }

    new place = -1;

    if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
    {
        place = Jobs_FindPlace(playerid);
    }

    if (place == -1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not even near a place to get a Job !");
        return 1;
    }

    if (Jobs_PlaceBarsFamilies(place) && Jobs_IsInFamily(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Families cannot take on this Job !");
        return 1;
    }

    new job = Jobs_GetPlaceJob(place), name[JOBS_NAME_LEN], line[JOBS_LINE_LEN];
    Jobs_GetName(job,name);

    format(line,sizeof(line),"* You are about to become %s %s, and get a 5 hour Contract.",Util_StartsWithVowel(name) ? ("an") : ("a"),name);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You have to fulfill this Contract first, if you want to Quit the job later.");
    format(line,sizeof(line),"* If you are sure to become %s %s, type /accept job.",Util_StartsWithVowel(name) ? ("an") : ("a"),name);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    Jobs_SetPending(playerid,job);
    return 1;
}

CMD:quitjob(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Jobs_GetJob(playerid) <= JOB_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You don't even have a Job !");
        return 1;
    }

    if (Account_GetDonateRank(playerid) > 0)
    {
        if (Jobs_GetContractTime(playerid) >= JOBS_CONTRACT_DONOR)
        {
            Jobs_QuitFinish(playerid,"* You already fulfilled your 1 hour Contract, and quit your Job.");
        }
        else
        {
            Jobs_QuitWait(playerid,JOBS_CONTRACT_DONOR);
        }

        return 1;
    }

    if (Jobs_GetContractTime(playerid) >= JOBS_CONTRACT_FULL)
    {
        Jobs_QuitFinish(playerid,"* You already fulfilled your 5 hour Contract, and quit your Job.");
    }
    else
    {
        Jobs_QuitWait(playerid,JOBS_CONTRACT_FULL);
    }

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
public Jobs_AcceptJob(playerid,const params[])
{
    new pending = Jobs_GetPending(playerid);

    if (pending <= JOB_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You haven't even been at a Job place yet!");
        return 1;
    }

    if (Jobs_IsInFamily(playerid) && pending != JOB_LAWYER && pending != JOB_CARJACKER && pending != JOB_CARDEALER)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Can't get a Job, you are in a Family !");
        return 1;
    }

    SendClientMessage(playerid,COLOR_LIGHTBLUE,"* Now that you have confirmed you want the Job, you got a 5 hour Contract.");
    SendClientMessage(playerid,COLOR_LIGHTBLUE,"* Congratulations with your new Job, type /help to see your new command.");
    Jobs_SetJob(playerid,pending);
    Jobs_SetPending(playerid,JOB_NONE);
    return 1;
}

Timer_Declare(Jobs_ContractTimer)
{
    Jobs_TickContracts();
    return true;
}
