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
#define INSTRUCTOR_LINE_LEN (144)
#define INSTRUCTOR_RANK_GIVE (3)
#define INSTRUCTOR_LICENSE_COUNT (5)
#define INSTRUCTOR_NAME_LEN (16)

static const s_InstructorNames[INSTRUCTOR_LICENSE_COUNT][INSTRUCTOR_NAME_LEN] =
{
    "driving",
    "flying",
    "sailing",
    "fishing",
    "weapon"
};

static const s_InstructorUsageNames[INSTRUCTOR_LICENSE_COUNT][INSTRUCTOR_NAME_LEN] =
{
    "driverslicense",
    "flyinglicense",
    "sailinglicense",
    "fishinglicense",
    "weaponlicense"
};

static const s_InstructorTitles[INSTRUCTOR_LICENSE_COUNT][INSTRUCTOR_NAME_LEN] =
{
    "Drivers License",
    "Flying License",
    "Sailing License",
    "Fishing License",
    "Weapon License"
};

static const s_InstructorLicenses[INSTRUCTOR_LICENSE_COUNT] =
{
    LICENSE_CAR,
    LICENSE_FLY,
    LICENSE_BOAT,
    LICENSE_FISH,
    LICENSE_GUN
};

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
static bool:Instructor_ReadTarget(playerid,const params[],const usage[],&targetid)
{
    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_WHITE,usage);
        return false;
    }

    if (!Util_IsValidPlayer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return false;
    }

    return true;
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
CMD:givelicense(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Factions_IsInstructor(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a School Instructor !");
        return 1;
    }

    if (Factions_GetRank(playerid) < INSTRUCTOR_RANK_GIVE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Only Rank 3 or higher can give away a License !");
        return 1;
    }

    new name[INSTRUCTOR_NAME_LEN], rest[48];

    if (sscanf(params,"s[16]S()[48]",name,rest))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /givelicense [name] [playerid/PartOfName]");
        SendClientMessage(playerid,COLOR_WHITE,"Available names: Driving, Flying, Sailing, Fishing, Weapon.");
        return 1;
    }

    for (new i = 0;i < INSTRUCTOR_LICENSE_COUNT;i++)
    {
        if (strcmp(name,s_InstructorNames[i],true) != 0)
        {
            continue;
        }

        new usage[64], targetid;
        format(usage,sizeof(usage),"USAGE: /givelicense %s [playerid/PartOfName]",s_InstructorUsageNames[i]);

        if (!Instructor_ReadTarget(playerid,rest,usage,targetid))
        {
            return 1;
        }

        new instructorName[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[INSTRUCTOR_LINE_LEN];
        GetPlayerName(playerid,instructorName,sizeof(instructorName));
        GetPlayerName(targetid,targetName,sizeof(targetName));
        format(line,sizeof(line),"* You've given a %s to %s.",s_InstructorTitles[i],targetName);
        SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
        format(line,sizeof(line),"* Instructor %s has given you a %s.",instructorName,s_InstructorTitles[i]);
        SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
        License_Set(targetid,s_InstructorLicenses[i],1);
        return 1;
    }

    return 1;
}

CMD:startlesson(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Factions_IsInstructor(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a School Instructor !");
        return 1;
    }

    new targetid;

    if (!Instructor_ReadTarget(playerid,params,"USAGE: /startlesson [playerid/PartOfName]",targetid))
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[INSTRUCTOR_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You've started %s's Lesson.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* Instructor %s has started your Lesson.",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    Vehicles_SetLessonActive(targetid,true);
    return 1;
}

CMD:stoplesson(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Factions_IsInstructor(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a School Instructor !");
        return 1;
    }

    new targetid;

    if (!Instructor_ReadTarget(playerid,params,"USAGE: /stoplesson [playerid/PartOfName]",targetid))
    {
        return 1;
    }

    if (!Vehicles_IsLessonActive(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not taking a Lesson !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[INSTRUCTOR_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You've stopped %s's Lesson.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* Instructor %s has stopped your Lesson.",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    Vehicles_SetLessonActive(targetid,false);
    return 1;
}
