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
#define LAWYER_UNLIMITED_SKILL (401)

static bool:s_LawyerApproved[MAX_PLAYERS];

forward Lawyer_Accept(playerid,const params[]);
forward Lawyer_Cancel(playerid,const params[]);

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

static Lawyer_AnnounceLevel(playerid,skill)
{
    new reached = Jobs_GetSkillLevelReached(skill), line[JOBS_LINE_LEN];

    if (reached == 0)
    {
        return;
    }

    format(line,sizeof(line),"* Your Lawyer Skill is now Level %d, you will earn more Money and quicker Reload Time.",reached);
    SendClientMessage(playerid,COLOR_YELLOW,line);
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
CMD:free(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Jobs_Is(playerid,JOB_LAWYER))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Lawyer!");
        return 1;
    }

    if (Progress_GetSkill(playerid,PROGRESS_SKILL_LAW) >= LAWYER_UNLIMITED_SKILL)
    {
        s_LawyerApproved[playerid] = true;
    }

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /free [playerid/PartOfName]");
        return 1;
    }

    if (!Util_IsValidPlayer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is offline!");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"You cannot Free yourself!");
        return 1;
    }

    if (Law_GetJailed(targetid) != LAW_JAIL_CELL || !s_LawyerApproved[playerid])
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   Player didn't need a Lawyer / Player isn't Jailed !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You freed %s out of jail.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* You were freed out of jail, by Lawyer %s.",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    s_LawyerApproved[playerid] = false;
    Law_CancelLawyer(targetid);
    Law_SetBail(targetid,0);
    Law_SetJailTime(targetid,1);
    Lawyer_AnnounceLevel(playerid,Progress_AddSkill(playerid,PROGRESS_SKILL_LAW));
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
public Lawyer_Accept(playerid,const params[])
{
    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /accept lawyer [playerid/PartOfName]");
        return 1;
    }

    if (!Law_IsPoliceOrLeader(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"Invalid action! (You are no cop / Player isn't a Lawyer / Bad ID)");
        return 1;
    }

    if (!Util_IsValidPlayer(targetid) || !Jobs_Is(targetid,JOB_LAWYER))
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You allowed %s to free a Jailed Person.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* Officer %s approved (allowed) you to free a Jailed Person. (use /free)",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    s_LawyerApproved[targetid] = true;
    return 1;
}

public Lawyer_Cancel(playerid,const params[])
{
    Law_CancelLawyer(playerid);
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
    s_LawyerApproved[playerid] = false;
}

hook OnPlayerDisconnect(playerid,reason)
{
    s_LawyerApproved[playerid] = false;
}

hook Law_OnLawyerRequested(playerid)
{
    new name[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"** %s is in Jail, and needs a Lawyer. Go to the Police Station.",name);
    Jobs_SendJobMessage(JOB_LAWYER,TEAM_AZTECAS_COLOR,line);
    Jobs_SendJobMessage(JOB_LAWYER,TEAM_AZTECAS_COLOR,"* When you are at the Police Station, ask an Officer to approve you with /accept lawyer.");
}
