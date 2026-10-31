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

forward Families_LoadOnBoot();

static Families_BootTask()
{
    yield 1;

    await Families_LoadAll();
    await Turfs_LoadAll();
    Log_Info("families","%d turfs loaded",Turfs_GetCount());
    Boot_LoaderDone();
}

public Families_LoadOnBoot()
{
    Families_BootTask();
    return 1;
}

hook OnGameModeInit()
{
    Player_RegisterLoader(FAMILIES_LOADER);
    Boot_RegisterLoader("Families_LoadOnBoot");
    Factions_SetPredicate(FACTION_PREDICATE_IN_FAMILY,"Families_PredicateInFamily");
}

hook OnMigrationRun()
{
    Migration_Add("families-1-families", "CREATE TABLE IF NOT EXISTS families (family_id INT UNSIGNED NOT NULL, taken INT NOT NULL DEFAULT 0, name VARCHAR(20) NOT NULL DEFAULT 'None', motd VARCHAR(128) NOT NULL DEFAULT 'None', colour VARCHAR(20) NOT NULL DEFAULT '0xFF000069', leader VARCHAR(25) NOT NULL DEFAULT 'None', members INT NOT NULL DEFAULT 0, spawn_x FLOAT NOT NULL DEFAULT 0, spawn_y FLOAT NOT NULL DEFAULT 0, spawn_z FLOAT NOT NULL DEFAULT 0, spawn_angle FLOAT NOT NULL DEFAULT 0, interior INT NOT NULL DEFAULT 0, PRIMARY KEY (family_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("families-2-turfs", "CREATE TABLE IF NOT EXISTS turfs (turf_id INT UNSIGNED NOT NULL, owner VARCHAR(64) NOT NULL DEFAULT 'None', colour VARCHAR(20) NOT NULL DEFAULT '0xFF000069', min_x FLOAT NOT NULL, min_y FLOAT NOT NULL, max_x FLOAT NOT NULL, max_y FLOAT NOT NULL, PRIMARY KEY (turf_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("families-3-player-families", "CREATE TABLE IF NOT EXISTS player_families (account_id INT UNSIGNED NOT NULL, family INT NOT NULL DEFAULT 255, family_rank INT NOT NULL DEFAULT 0, PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}
