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
    Player_RegisterLoader(JOBS_LOADER);
    Help_RegisterReader(HELP_FIELD_JOB,"Jobs_ReadJob");
    Factions_SetPredicate(FACTION_PREDICATE_HAS_JOB,"Jobs_PredicateHasJob");
    Offer_RegisterAccept("job","Jobs_AcceptJob");
    Offer_RegisterAccept("medic","Jobs_AcceptMedic");
    Offer_RegisterCancel("medic","Jobs_CancelMedic");
    Offer_RegisterAccept("ticket","Jobs_AcceptTicket");
    Offer_RegisterCancel("ticket","Jobs_CancelTicket");
    Service_Register("medic","Jobs_ServiceMedic");
    Timer_Start(Jobs_ContractTimer,JOBS_CONTRACT_TICK_MS);
}

hook OnMigrationRun()
{
    Migration_Add("jobs-1-player-jobs", "CREATE TABLE IF NOT EXISTS player_jobs (account_id INT UNSIGNED NOT NULL, job INT NOT NULL DEFAULT 0, contract_time INT NOT NULL DEFAULT 0, PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}
