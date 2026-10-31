/**
 *      ______                                   __      __
 *     /      \                                 |  \    |  |
 *    |  $$$$$$\ __    __  _______    _______  _| $$_    \$$  ______   _______    _______
 *    | $$_  \$$|  \  |  \|       \  /       \|   $$ \  |  \ /      \ |       \  /       |
 *    | $$ \    | $$  | $$| $$$$$$$\|  $$$$$$$ \$$$$$$  | $$|  $$$$$$\| $$$$$$$\|  $$$$$$$
 *    | $$$$    | $$  | $$| $$  | $$| $$        | $$ __ | $$| $$  | $$| $$  | $$ \$$    |
 *    | $$      | $$__/ $$| $$  | $$| $$_____   | $$|  \| $$| $$__/ $$| $$  | $$ _\$$$$$$|
 *    | $$       \$$    $$| $$  | $$ \$$     \   \$$  $$| $$ \$$    $$| $$  | $$|       $$
 *     \$$        \$$$$$$  \$$   \$$  \$$$$$$$    \$$$$  \$$  \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
forward Vehicles_LoadOnBoot();

static Vehicles_BootTask()
{
    yield 1;

    await Vehicles_LoadWorld();
    Boot_LoaderDone();
}

public Vehicles_LoadOnBoot()
{
    Vehicles_BootTask();
    return 1;
}

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
    Vehicles_ResetShops();
    Boot_RegisterLoader("Vehicles_LoadOnBoot");
}

hook OnMigrationRun()
{
    Migration_Add("vehicles-1-world", "CREATE TABLE IF NOT EXISTS vehicles (id INT UNSIGNED NOT NULL, kind TINYINT UNSIGNED NOT NULL DEFAULT 1, model SMALLINT NOT NULL DEFAULT 0, color1 SMALLINT NOT NULL DEFAULT -1, color2 SMALLINT NOT NULL DEFAULT -1, x FLOAT NOT NULL DEFAULT 0, y FLOAT NOT NULL DEFAULT 0, z FLOAT NOT NULL DEFAULT 0, angle FLOAT NOT NULL DEFAULT 0, respawn INT NOT NULL DEFAULT 60000, interior SMALLINT NOT NULL DEFAULT 0, classes INT NOT NULL DEFAULT 0, gates INT NOT NULL DEFAULT 0, shop SMALLINT NOT NULL DEFAULT -1, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}
