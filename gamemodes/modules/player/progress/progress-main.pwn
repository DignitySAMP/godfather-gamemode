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
    Player_RegisterLoader(PROGRESS_LOADER);
    Command_SetDenial("buylevel", E_COMMAND_DENIAL_LOGIN, COLOR_GRAD1, "   You are not Logged in !");
}

hook OnMigrationRun()
{
    Migration_Add("progress-1-player-progress", "CREATE TABLE IF NOT EXISTS player_progress (account_id INT UNSIGNED NOT NULL, upgrade_points INT NOT NULL DEFAULT 0, spawn_health FLOAT NOT NULL DEFAULT 0, perk_alcohol INT NOT NULL DEFAULT 0, perk_drug INT NOT NULL DEFAULT 0, perk_miser INT NOT NULL DEFAULT 0, perk_trader INT NOT NULL DEFAULT 0, perk_pain INT NOT NULL DEFAULT 0, skill_detective INT NOT NULL DEFAULT 0, skill_sex INT NOT NULL DEFAULT 0, skill_box INT NOT NULL DEFAULT 0, skill_law INT NOT NULL DEFAULT 0, skill_mech INT NOT NULL DEFAULT 0, skill_jack INT NOT NULL DEFAULT 0, skill_car INT NOT NULL DEFAULT 0, skill_news INT NOT NULL DEFAULT 0, skill_drugs INT NOT NULL DEFAULT 0, skill_cook INT NOT NULL DEFAULT 0, skill_fish INT NOT NULL DEFAULT 0, PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}
