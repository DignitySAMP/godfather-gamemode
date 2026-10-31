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
    Player_RegisterLoader(HITMAN_LOADER);
    Chat_RegisterInterceptor("Hitman_ChatLaptop",CHAT_SLOT_HITMAN_PC);
    Hints_RegisterAction(1073.0619,-344.5148,73.9922,HITMAN_HQ_RADIUS,"Hitman_PickupPackage");
}

hook OnMigrationRun()
{
    Migration_Add("hitman-1-player-hitman", "CREATE TABLE IF NOT EXISTS player_hitman (account_id INT UNSIGNED NOT NULL, head_value INT NOT NULL DEFAULT 0, PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}
