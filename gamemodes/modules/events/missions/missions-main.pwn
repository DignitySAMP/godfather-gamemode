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

hook OnGameModeInit()
{
    Player_RegisterLoader(MISSIONS_LOADER);
    Jobs_SetMissionCheck("Missions_PredicateOnMission");
    Houses_SetPredicate(HOUSE_PREDICATE_ON_MISSION,"Missions_PredicateOnMission");
    Command_SetDenial("mk",E_COMMAND_DENIAL_LEVEL,COLOR_GREY,"   You are not an Admin !");
    Hints_Register(MISSIONS_BOARD_X,MISSIONS_BOARD_Y,MISSIONS_BOARD_Z,MISSIONS_HINT_RADIUS,"~g~Welcome,~n~~y~Use /mission to take on a Mission",3,true);
}

hook OnMigrationRun()
{
    new sql[2400];
    Missions_BuildTableSql(sql);
    Migration_Add("missions-1-missions",sql);
    Migration_Add("missions-2-player-missions","CREATE TABLE IF NOT EXISTS player_missions (account_id INT UNSIGNED NOT NULL, mission_nr INT NOT NULL DEFAULT 0, PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}

hook OnPlayerConnect(playerid)
{
    Missions_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Missions_Reset(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    SetTimerEx("Missions_LoadStart",0,false,"ddd",playerid,accountid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Missions_Reset(playerid);
}

hook OnPlayerSpawn(playerid)
{
    Missions_Fail(playerid);
}

hook OnPlayerEnterCheckpoint(playerid)
{
    Missions_ReachCheckpoint(playerid);
}

hook Tick_OnPlayerSecond(playerid)
{
    if (Player_IsReady(playerid))
    {
        Missions_Watch(playerid);
    }
}
