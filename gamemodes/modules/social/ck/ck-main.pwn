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
    Boot_RegisterLoader("Ck_LoadOnBoot");
    Command_SetDenial("cks",E_COMMAND_DENIAL_LEVEL,COLOR_GREY,"   You are not an Admin !");
}

hook OnMigrationRun()
{
    Migration_Add("ck-1-requests", "CREATE TABLE IF NOT EXISTS ck_requests (slot_id TINYINT UNSIGNED NOT NULL, sender VARCHAR(32) NOT NULL DEFAULT 'No-one', target VARCHAR(32) NOT NULL DEFAULT 'No-one', used TINYINT NOT NULL DEFAULT 0, PRIMARY KEY (slot_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}

hook OnPlayerConnect(playerid)
{
    Ck_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Ck_HandleDisconnect(playerid);
    Ck_Reset(playerid);
}

hook Death_OnKilled(playerid,killerid,reason)
{
    Ck_HandleDeath(playerid,killerid);
}
