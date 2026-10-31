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
    Player_RegisterLoader(DRUGS_LOADER);
    Offer_RegisterAccept("drugs","Drugs_Accept");
    Offer_RegisterCancel("drugs","Drugs_Cancel");
    Get_Register("drugs","Drugs_GetDrugs");
    Get_Register("fuel","Drugs_GetFuel");
    Hints_Register(323.0342,1118.5804,1083.8828,HINTS_RADIUS,"~w~Type /get drugs, to get some ~r~Drugs~y~~n~Skill Level matters to price");
}

hook OnMigrationRun()
{
    Migration_Add("drugs-1-player-drugs", "CREATE TABLE IF NOT EXISTS player_drugs (account_id INT UNSIGNED NOT NULL, drugs INT NOT NULL DEFAULT 0, PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}
