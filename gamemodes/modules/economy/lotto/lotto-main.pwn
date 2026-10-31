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
forward Lotto_LoadOnBoot();

static Lotto_BootTask()
{
    yield 1;

    await Lotto_LoadState();
    Boot_LoaderDone();
}

public Lotto_LoadOnBoot()
{
    Lotto_BootTask();
    return 1;
}

#include <pp-hooks>

hook OnGameModeInit()
{
    Player_RegisterLoader(LOTTO_LOADER);
    Boot_RegisterLoader("Lotto_LoadOnBoot");
    Command_SetDenial("startlotto",E_COMMAND_DENIAL_LEVEL,COLOR_GREY,"   You are not an Admin !");
}

hook OnMigrationRun()
{
    Migration_Add("lotto-1-tickets", "CREATE TABLE IF NOT EXISTS lotto_tickets (account_id INT UNSIGNED NOT NULL, ticket INT NOT NULL DEFAULT 0, PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("lotto-2-state", "CREATE TABLE IF NOT EXISTS lotto_state (id TINYINT UNSIGNED NOT NULL, jackpot INT NOT NULL DEFAULT 250000, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("lotto-3-state-seed", "INSERT IGNORE INTO lotto_state (id, jackpot) VALUES (1, 250000)");
}
