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
#define DETECTIVE_CHECKPOINT_SIZE (6.0)
#define DETECTIVE_COOLDOWN_SECONDS (120)
#define DETECTIVE_UNLIMITED_SKILL (401)
#define DETECTIVE_SOUND (1056)

static s_DetectiveFindTime[MAX_PLAYERS];
static s_DetectiveFindPoints[MAX_PLAYERS];
static s_DetectiveUsedFind[MAX_PLAYERS];

static const s_DetectiveSeconds[5] = {4, 6, 8, 10, 12};

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

static Detective_Reset(playerid)
{
    s_DetectiveFindTime[playerid] = 0;
    s_DetectiveFindPoints[playerid] = 0;
    s_DetectiveUsedFind[playerid] = 0;
}

static Detective_AnnounceLevel(playerid,skill)
{
    new reached = Jobs_GetSkillLevelReached(skill), line[JOBS_LINE_LEN];

    if (reached == 0)
    {
        return;
    }

    if (reached <= 3)
    {
        format(line,sizeof(line),"* Your Detective Skill is now Level %d, soon you are able to find Faction Members.",reached);
    }
    else
    {
        format(line,sizeof(line),"* Your Detective Skill is now Level %d, you are now able to find Faction Members.",reached);
    }

    SendClientMessage(playerid,COLOR_YELLOW,line);
}

static Detective_Tick(playerid)
{
    if (s_DetectiveUsedFind[playerid] >= 1)
    {
        s_DetectiveUsedFind[playerid]++;

        if (s_DetectiveUsedFind[playerid] >= DETECTIVE_COOLDOWN_SECONDS)
        {
            s_DetectiveUsedFind[playerid] = 0;
        }
    }

    if (s_DetectiveFindTime[playerid] <= 0)
    {
        return;
    }

    if (s_DetectiveFindTime[playerid] == s_DetectiveFindPoints[playerid])
    {
        s_DetectiveFindTime[playerid] = 0;
        s_DetectiveFindPoints[playerid] = 0;
        DisablePlayerCheckpoint(playerid);
        PlayerPlaySound(playerid,DETECTIVE_SOUND,0.0,0.0,0.0);
        GameTextForPlayer(playerid,"~r~RedMarker gone",2500,1);
        return;
    }

    new text[8];
    format(text,sizeof(text),"%d",s_DetectiveFindPoints[playerid] - s_DetectiveFindTime[playerid]);
    GameTextForPlayer(playerid,text,1500,6);
    s_DetectiveFindTime[playerid]++;
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
CMD:find(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Jobs_Is(playerid,JOB_DETECTIVE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Detective !");
        return 1;
    }

    if (Jobs_IsOnMission(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   On a mission right now, can't use this command !");
        return 1;
    }

    new skill = Progress_GetSkill(playerid,PROGRESS_SKILL_DETECTIVE);

    if (s_DetectiveUsedFind[playerid] != 0 && skill < DETECTIVE_UNLIMITED_SKILL)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You've already searched for someone, wait 2 minutes !");
        return 1;
    }

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /find [playerid/PartOfName]");
        return 1;
    }

    if (!Util_IsValidPlayer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Invalid Name/ID !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"You cannot Find yourself!");
        return 1;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid,x,y,z);
    SetPlayerCheckpoint(playerid,x,y,z,DETECTIVE_CHECKPOINT_SIZE);
    s_DetectiveFindTime[playerid] = 1;
    s_DetectiveFindPoints[playerid] = s_DetectiveSeconds[Jobs_GetSkillTier(skill)];
    s_DetectiveUsedFind[playerid] = 1;
    Detective_AnnounceLevel(playerid,Progress_AddSkill(playerid,PROGRESS_SKILL_DETECTIVE));
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

hook OnPlayerConnect(playerid)
{
    Detective_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Detective_Reset(playerid);
}

hook Tick_OnPlayerSecond(playerid)
{
    Detective_Tick(playerid);
}
