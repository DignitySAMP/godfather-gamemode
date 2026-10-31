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
    Player_RegisterLoader(BOXING_LOADER);
    Boot_RegisterLoader(BOXING_BOOT_LOADER);
    Offer_RegisterAccept("boxing","Boxing_Accept");
    Offer_RegisterCancel("boxing","Boxing_Cancel");
    Cooking_SetFightCheck("Boxing_FightCheck");
}

hook OnMigrationRun()
{
    Migration_Add("boxing-1-player-boxing", "CREATE TABLE IF NOT EXISTS player_boxing (account_id INT UNSIGNED NOT NULL, wins INT NOT NULL DEFAULT 0, loses INT NOT NULL DEFAULT 0, PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("boxing-2-champion", "CREATE TABLE IF NOT EXISTS boxing_champion (id INT UNSIGNED NOT NULL, wins INT NOT NULL DEFAULT 0, name VARCHAR(24) NOT NULL DEFAULT '', loses INT NOT NULL DEFAULT 0, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}
