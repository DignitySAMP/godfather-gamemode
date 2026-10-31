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
    Command_SetDenial("check",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD1,"   You are not an admin");
    Command_SetDenial("prison",E_COMMAND_DENIAL_LEVEL,COLOR_GREY,"   you are not authorized to use this command !");
    Staff_SetSpectatorRunning(true);
    Timer_Start(Staff_IdleKickTimer,STAFF_IDLE_MS);
}

hook OnMigrationRun()
{
    Migration_Add("staff-1-staff-log","CREATE TABLE IF NOT EXISTS staff_log (id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, kind VARCHAR(8) NOT NULL, line VARCHAR(255) NOT NULL, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id), KEY idx_kind (kind, id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}

hook Economy_OnPayLog(const text[])
{
    Staff_PayLog(text);
}

hook OnPlayerConnect(playerid)
{
    Staff_ResetPlayer(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Staff_ResetPlayer(playerid);
}
