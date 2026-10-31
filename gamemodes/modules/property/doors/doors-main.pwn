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

forward SaDoors_LoadOnBoot();

static SaDoors_BootTask()
{
    yield 1;

    await SaDoors_LoadAll();
    SaDoors_RegisterPlain();
    Boot_LoaderDone();
}

public SaDoors_LoadOnBoot()
{
    SaDoors_BootTask();
    return 1;
}

hook OnGameModeInit()
{
    Boot_RegisterLoader("SaDoors_LoadOnBoot");
    Doors_RegisterFixed();
}

hook OnMigrationRun()
{
    Migration_Add("doors-1-sa-doors", "CREATE TABLE IF NOT EXISTS sa_doors (door_id INT UNSIGNED NOT NULL, name VARCHAR(11) NOT NULL, kind VARCHAR(5) NOT NULL, door_type VARCHAR(11) NOT NULL DEFAULT '', interior INT NOT NULL DEFAULT 0, out_x FLOAT NOT NULL, out_y FLOAT NOT NULL, out_z FLOAT NOT NULL, out_angle FLOAT NOT NULL, in_x FLOAT NOT NULL, in_y FLOAT NOT NULL, in_z FLOAT NOT NULL, in_angle FLOAT NOT NULL, title VARCHAR(31) NOT NULL DEFAULT '', price INT NOT NULL DEFAULT 0, level INT NOT NULL DEFAULT 0, PRIMARY KEY (door_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}
