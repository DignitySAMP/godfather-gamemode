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
    Boot_RegisterLoader("Irc_LoadOnBoot");
    Command_SetDenial("makeircadmin",E_COMMAND_DENIAL_LEVEL,COLOR_GREY,"   you are not authorized to do that !");
}

hook OnMigrationRun()
{
    Migration_Add("irc-1-channels", "CREATE TABLE IF NOT EXISTS irc_channels (channel_id TINYINT UNSIGNED NOT NULL, admin VARCHAR(32) NOT NULL DEFAULT '', motd VARCHAR(128) NOT NULL DEFAULT '', password VARCHAR(128) NOT NULL DEFAULT '', need_pass TINYINT NOT NULL DEFAULT 0, locked TINYINT NOT NULL DEFAULT 0, PRIMARY KEY (channel_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("irc-2-channels-seed", "INSERT IGNORE INTO irc_channels (channel_id) VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9)");
}

hook OnPlayerConnect(playerid)
{
    Irc_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Irc_Reset(playerid);
}
