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
    Player_RegisterLoader(LAW_LOADER);
    Chat_RegisterInterceptor("Law_ChatLawyer",CHAT_SLOT_LAWYER);
    Factions_SetPredicate(FACTION_PREDICATE_IS_JAILED,"Law_PredicateIsJailed");
    Misc_SetJailProvider("Law_ReadJailTime");
    Weapons_SetBlockCheck("Law_PredicateIsJailed");
    Timer_Start(Law_DecayTimer,LAW_DECAY_MS);
}

hook OnMigrationRun()
{
    Migration_Add("law-1-player-law", "CREATE TABLE IF NOT EXISTS player_law (account_id INT UNSIGNED NOT NULL, crimes INT NOT NULL DEFAULT 0, arrested INT NOT NULL DEFAULT 0, wanted_deaths INT NOT NULL DEFAULT 0, jailed INT NOT NULL DEFAULT 0, jail_time INT NOT NULL DEFAULT 0, PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}
