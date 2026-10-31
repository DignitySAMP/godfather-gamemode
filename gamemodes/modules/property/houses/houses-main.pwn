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
    Player_RegisterLoader(HOUSES_LOADER);
    Boot_RegisterLoader("Houses_LoadOnBoot");
}

hook OnMigrationRun()
{
    Migration_Add("houses-1-table", "CREATE TABLE IF NOT EXISTS houses (house_id INT UNSIGNED NOT NULL, entrance_x FLOAT NOT NULL, entrance_y FLOAT NOT NULL, entrance_z FLOAT NOT NULL, exit_x FLOAT NOT NULL, exit_y FLOAT NOT NULL, exit_z FLOAT NOT NULL, health_x INT NOT NULL DEFAULT 0, health_y INT NOT NULL DEFAULT 0, health_z INT NOT NULL DEFAULT 0, armour_x INT NOT NULL DEFAULT 0, armour_y INT NOT NULL DEFAULT 0, armour_z INT NOT NULL DEFAULT 0, owner VARCHAR(24) NOT NULL DEFAULT 'The State', description VARCHAR(32) NOT NULL DEFAULT '', price INT NOT NULL DEFAULT 0, health_upgrade INT NOT NULL DEFAULT 0, armour_upgrade INT NOT NULL DEFAULT 0, interior INT NOT NULL DEFAULT 0, locked INT NOT NULL DEFAULT 1, owned INT NOT NULL DEFAULT 0, rooms INT NOT NULL DEFAULT 0, rent INT NOT NULL DEFAULT 0, rentable INT NOT NULL DEFAULT 0, takings INT NOT NULL DEFAULT 0, car_model INT NOT NULL DEFAULT 418, car_colour1 INT NOT NULL DEFAULT -1, car_colour2 INT NOT NULL DEFAULT -1, seen_day INT NOT NULL DEFAULT 0, level INT NOT NULL DEFAULT 0, PRIMARY KEY (house_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("houses-2-keys", "CREATE TABLE IF NOT EXISTS house_keys (account_id INT UNSIGNED NOT NULL, house_key INT NOT NULL DEFAULT 255, PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("houses-3-angles", "ALTER TABLE houses ADD COLUMN entrance_angle FLOAT NOT NULL DEFAULT 1000, ADD COLUMN exit_angle FLOAT NOT NULL DEFAULT 1000");
}
