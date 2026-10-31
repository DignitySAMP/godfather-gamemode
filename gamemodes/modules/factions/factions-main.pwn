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
    Player_RegisterLoader(FACTIONS_LOADER);
    Chat_RegisterInterceptor("Factions_ChatCharSelect",CHAT_SLOT_CLOTHES);
    Help_RegisterReader(HELP_FIELD_MEMBER,"Factions_ReadMember");
    Help_RegisterReader(HELP_FIELD_LEADER,"Factions_ReadLeader");
    Houses_SetPredicate(HOUSE_PREDICATE_IS_COP,"Factions_HouseIsCop");
    Doors_Register(DOOR_KIND_FIXED,FACTION_DOOR_HITMAN_HQ,1073.0619,-344.5148,73.9922,1205.0947,-10.1685,1000.9219,2,242,3.0,3.0,DOOR_FLAG_NONE,DOOR_WORLD_KEEP,"Factions_HitmanDoorCheck");
}

hook OnMigrationRun()
{
    Migration_Add("factions-1-player-factions", "CREATE TABLE IF NOT EXISTS player_factions (account_id INT UNSIGNED NOT NULL, leader INT NOT NULL DEFAULT 0, member INT NOT NULL DEFAULT 0, faction_rank INT NOT NULL DEFAULT 0, PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}
