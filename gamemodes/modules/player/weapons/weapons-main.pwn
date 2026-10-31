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
    Player_RegisterLoader(WEAPONS_LOADER);
}

hook OnMigrationRun()
{
    Migration_Add("weapons-1-player-weapons", "CREATE TABLE IF NOT EXISTS player_weapons (account_id INT UNSIGNED NOT NULL, gun1 INT NOT NULL DEFAULT 0, gun2 INT NOT NULL DEFAULT 0, gun3 INT NOT NULL DEFAULT 0, gun4 INT NOT NULL DEFAULT 0, ammo1 INT NOT NULL DEFAULT 0, ammo2 INT NOT NULL DEFAULT 0, ammo3 INT NOT NULL DEFAULT 0, ammo4 INT NOT NULL DEFAULT 0, PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}
