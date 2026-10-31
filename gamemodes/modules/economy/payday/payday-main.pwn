/**
 *                        __  __  __                            __
 *                       |  \|  \|  \                          |  |
 *      _______  ______  | $$| $$| $$____    ______    _______ | $$   __   _______
 *     /       \|      \ | $$| $$| $$    \  |      \  /       \| $$  /  \ /       |
 *    |  $$$$$$$ \$$$$$$\| $$| $$| $$$$$$$\  \$$$$$$\|  $$$$$$$| $$_/  $$|  $$$$$$$
 *    | $$      /      $$| $$| $$| $$  | $$ /      $$| $$      | $$   $$  \$$    |
 *    | $$_____|  $$$$$$$| $$| $$| $$__/ $$|  $$$$$$$| $$_____ | $$$$$$\  _\$$$$$$|
 *     \$$     \\$$    $$| $$| $$| $$    $$ \$$    $$ \$$     \| $$  \$$\|       $$
 *      \$$$$$$$ \$$$$$$$ \$$ \$$ \$$$$$$$   \$$$$$$$  \$$$$$$$ \$$   \$$ \$$$$$$$
 *
 */
forward Payday_LoadOnBoot();

static Payday_BootTask()
{
    yield 1;

    await Payday_LoadTax();
    Boot_LoaderDone();
}

public Payday_LoadOnBoot()
{
    Payday_BootTask();
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
    Player_RegisterLoader(PAYDAY_LOADER);
    Boot_RegisterLoader("Payday_LoadOnBoot");
    Payday_InitClock();
    Timer_Start(Payday_ClockTimer,PAYDAY_CLOCK_MS);
    Timer_Start(Payday_EligibilityTimer,PAYDAY_ELIGIBILITY_MS);
}

hook OnMigrationRun()
{
    Migration_Add("payday-1-players", "CREATE TABLE IF NOT EXISTS payday_players (account_id INT UNSIGNED NOT NULL, connect_time INT NOT NULL DEFAULT 0, paycheck INT NOT NULL DEFAULT 0, payday INT NOT NULL DEFAULT 0, payday_had INT NOT NULL DEFAULT 0, PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("payday-2-state", "CREATE TABLE IF NOT EXISTS payday_state (id TINYINT UNSIGNED NOT NULL, tax_pool INT NOT NULL DEFAULT 0, tax_value INT NOT NULL DEFAULT 0, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("payday-3-state-seed", "INSERT IGNORE INTO payday_state (id, tax_pool, tax_value) VALUES (1, 0, 0)");
}
