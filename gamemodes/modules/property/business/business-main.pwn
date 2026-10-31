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

forward Business_LoadOnBoot();

static Business_BootTask()
{
    yield 1;

    await Business_LoadAll();
    Business_SyncAllShops();
    Business_RegisterDoors();
    Business_RefreshAllPickups();
    Log_Info("business","%d businesses loaded",Business_CountLoaded());
    Boot_LoaderDone();
}

public Business_LoadOnBoot()
{
    Business_BootTask();
    return 1;
}

hook OnGameModeInit()
{
    Player_RegisterLoader(BUSINESS_LOADER);
    Boot_RegisterLoader("Business_LoadOnBoot");
    Business_RegisterLinks();
}

hook OnMigrationRun()
{
    Migration_Add("business-1-businesses", "CREATE TABLE IF NOT EXISTS businesses (business_id INT UNSIGNED NOT NULL, owned INT NOT NULL DEFAULT 0, owner VARCHAR(64) NOT NULL DEFAULT 'The State', message VARCHAR(128) NOT NULL DEFAULT '', extortion VARCHAR(24) NOT NULL DEFAULT 'No-one', entrance_x FLOAT NOT NULL, entrance_y FLOAT NOT NULL, entrance_z FLOAT NOT NULL, exit_x FLOAT NOT NULL, exit_y FLOAT NOT NULL, exit_z FLOAT NOT NULL, level_needed INT NOT NULL DEFAULT 0, buy_price INT NOT NULL DEFAULT 0, entrance_cost INT NOT NULL DEFAULT 0, till INT NOT NULL DEFAULT 0, locked INT NOT NULL DEFAULT 1, interior INT NOT NULL DEFAULT 0, products INT NOT NULL DEFAULT 0, max_products INT NOT NULL DEFAULT 0, price_prod INT NOT NULL DEFAULT 0, PRIMARY KEY (business_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("business-2-special", "CREATE TABLE IF NOT EXISTS special_businesses (special_id INT UNSIGNED NOT NULL, owned INT NOT NULL DEFAULT 0, owner VARCHAR(64) NOT NULL DEFAULT 'The State', message VARCHAR(128) NOT NULL DEFAULT '', extortion VARCHAR(24) NOT NULL DEFAULT 'No-one', entrance_x FLOAT NOT NULL, entrance_y FLOAT NOT NULL, entrance_z FLOAT NOT NULL, level_needed INT NOT NULL DEFAULT 0, buy_price INT NOT NULL DEFAULT 0, entrance_cost INT NOT NULL DEFAULT 0, till INT NOT NULL DEFAULT 0, locked INT NOT NULL DEFAULT 1, interior INT NOT NULL DEFAULT 0, products INT NOT NULL DEFAULT 0, max_products INT NOT NULL DEFAULT 0, price_prod INT NOT NULL DEFAULT 0, PRIMARY KEY (special_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("business-3-keys", "CREATE TABLE IF NOT EXISTS business_keys (account_id INT UNSIGNED NOT NULL, business_key INT NOT NULL DEFAULT 255, PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("business-4-typed", "ALTER TABLE businesses ADD COLUMN biz_type VARCHAR(12) NOT NULL DEFAULT '', ADD COLUMN entrance_angle FLOAT NOT NULL DEFAULT 1000, ADD COLUMN exit_angle FLOAT NOT NULL DEFAULT 1000");
    Migration_Add("business-5-typed-prices", BUSINESS_MIGRATION_TYPED_PRICES);
    Migration_Add("business-6-open-arenas", "UPDATE special_businesses SET locked = 0 WHERE special_id IN (10, 11) AND owned = 0 AND owner = 'The State'");
    Migration_Add("business-7-rental-fee", "UPDATE special_businesses SET entrance_cost = 100 WHERE special_id IN (0, 1) AND owned = 0 AND entrance_cost = 0");
}
