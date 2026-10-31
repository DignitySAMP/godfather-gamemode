/**
 *           __             __
 *          |  \           |  |
 *      ____| $$  ______  _| $$_     ______
 *     /      $$ |      \|   $$ \   |      |
 *    |  $$$$$$$  \$$$$$$\\$$$$$$    \$$$$$$|
 *    | $$  | $$ /      $$ | $$ __  /      $$
 *    | $$__| $$|  $$$$$$$ | $$|  \|  $$$$$$$
 *     \$$    $$ \$$    $$  \$$  $$ \$$    $$
 *      \$$$$$$$  \$$$$$$$   \$$$$   \$$$$$$$
 *
 */
#define MIGRATION_MAX (256)
#define MIGRATION_KEY_LEN (48)

static s_MigrationKeys[MIGRATION_MAX][MIGRATION_KEY_LEN];
static List:s_MigrationSql = List:0;
static s_MigrationCount;

static s_MigrationApplied[MIGRATION_MAX][MIGRATION_KEY_LEN];
static s_MigrationAppliedCount;
static s_MigrationRunning = -1;
static s_MigrationRan;
static s_MigrationSkipped;
static s_MigrationFailed;

#define BOOT_MAX_LOADERS (64)
#define BOOT_NAME_LEN (32)

enum E_BOOT_LOADER
{
    E_BOOT_NAME[BOOT_NAME_LEN],
    E_BOOT_AFTER[BOOT_NAME_LEN],
    bool:E_BOOT_DONE,
}

static s_BootLoaders[BOOT_MAX_LOADERS][E_BOOT_LOADER];
static s_BootLoaderCount;
static s_BootRunning = -1;

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
stock Migration_Add(const key[], const sql[])
{
    if (s_MigrationCount >= MIGRATION_MAX)
    {
        Log_Warn("migrations", "no room for %s", key);
        return;
    }

    if (s_MigrationSql == List:0)
    {
        s_MigrationSql = list_new();
    }

    format(s_MigrationKeys[s_MigrationCount], MIGRATION_KEY_LEN, "%s", key);
    list_add_str(s_MigrationSql, sql);
    s_MigrationCount++;
}

static bool:Migrations_IsListed(const keys[][], count, const key[])
{
    for (new i = 0;i < count;i++)
    {
        if (!strcmp(keys[i], key))
        {
            return true;
        }
    }

    return false;
}

stock Migrations_Run()
{
    pawn_call_public("OnMigrationRun", "");
    pawn_call_public("Migrations_RunOnBoot", "");
}

stock Boot_RegisterLoader(const name[], const after[] = "")
{
    if (s_BootLoaderCount >= BOOT_MAX_LOADERS)
    {
        Log_Error("boot", "no room for loader %s: raise BOOT_MAX_LOADERS, this loader would never run", name);
        return;
    }

    format(s_BootLoaders[s_BootLoaderCount][E_BOOT_NAME], BOOT_NAME_LEN, "%s", name);
    format(s_BootLoaders[s_BootLoaderCount][E_BOOT_AFTER], BOOT_NAME_LEN, "%s", after);
    s_BootLoaders[s_BootLoaderCount][E_BOOT_DONE] = false;
    s_BootLoaderCount++;
}

static bool:Boot_IsDone(const name[])
{
    for (new i = 0;i < s_BootLoaderCount;i++)
    {
        if (!strcmp(s_BootLoaders[i][E_BOOT_NAME], name))
        {
            return s_BootLoaders[i][E_BOOT_DONE];
        }
    }

    return true;
}

static Boot_Finish()
{
    s_BootRunning = -1;
    pawn_call_public("OnServerFinishLoading", "");
}

stock Boot_LoaderDone()
{
    if (s_BootRunning == -1)
    {
        return;
    }

    s_BootLoaders[s_BootRunning][E_BOOT_DONE] = true;
    s_BootRunning = -1;
    Boot_Next();
}

stock Boot_Run()
{
    if (!IsDatabaseReady())
    {
        Log_Warn("boot", "database not ready, %d loaders skipped", s_BootLoaderCount);
        Boot_Finish();
        return;
    }

    Migrations_Run();
}

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
forward OnMigrationRun();

public OnMigrationRun()
{
    return 1;
}

forward Migrations_RunOnBoot();

public Migrations_RunOnBoot()
{
    yield 1;

    await mysql_aquery_s(g_Mysql, str_new("CREATE TABLE IF NOT EXISTS schema_migrations (migration_key VARCHAR(48) NOT NULL, applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (migration_key)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"));

    s_MigrationAppliedCount = 0;

    await mysql_aquery_s(g_Mysql, str_new("SELECT migration_key FROM schema_migrations"));

    for (new row = 0, rows = cache_num_rows();row < rows && s_MigrationAppliedCount < MIGRATION_MAX;row++)
    {
        cache_get_value_name(row, "migration_key", s_MigrationApplied[s_MigrationAppliedCount], MIGRATION_KEY_LEN);
        s_MigrationAppliedCount++;
    }

    s_MigrationRan = 0;
    s_MigrationSkipped = 0;
    s_MigrationFailed = 0;

    Migrations_Step(0);
    return 1;
}

static Migrations_Step(from)
{
    for (new i = from;i < s_MigrationCount;i++)
    {
        if (Migrations_IsListed(s_MigrationApplied, s_MigrationAppliedCount, s_MigrationKeys[i]))
        {
            s_MigrationSkipped++;
            continue;
        }

        s_MigrationRunning = i;
        mysql_tquery_s(g_Mysql, list_get_str_s(s_MigrationSql, i), "Migrations_OnStatement", "d", i);
        return;
    }

    printf("[migrations] %d applied, %d already in place, %d failed", s_MigrationRan, s_MigrationSkipped, s_MigrationFailed);
    pawn_call_public("Boot_Next", "");
}

forward Migrations_OnStatement(index);

public Migrations_OnStatement(index)
{
    if (index != s_MigrationRunning)
    {
        return 1;
    }

    s_MigrationRunning = -1;
    mysql_pquery_s(g_Mysql, str_format("INSERT IGNORE INTO schema_migrations (migration_key) VALUES ('%e')", s_MigrationKeys[index]));
    s_MigrationRan++;

    Migrations_Step(index + 1);
    return 1;
}

#include <pp-hooks>

hook OnQueryError(errorid, const error[], const callback[], const query[], MySQL:handle)
{
    #pragma unused error
    #pragma unused query
    #pragma unused handle

    if (s_MigrationRunning == -1 || strcmp(callback, "Migrations_OnStatement") != 0)
    {
        return;
    }

    new index = s_MigrationRunning;
    s_MigrationRunning = -1;

    Log_Warn("migrations", "%s failed with error %d, it gets another go on the next boot", s_MigrationKeys[index], errorid);
    s_MigrationFailed++;

    Migrations_Step(index + 1);
}

forward Boot_Next();

public Boot_Next()
{
    new pending = 0;

    for (new i = 0;i < s_BootLoaderCount;i++)
    {
        if (s_BootLoaders[i][E_BOOT_DONE])
        {
            continue;
        }

        pending++;

        if (s_BootLoaders[i][E_BOOT_AFTER][0] != EOS && !Boot_IsDone(s_BootLoaders[i][E_BOOT_AFTER]))
        {
            continue;
        }

        s_BootRunning = i;
        pawn_call_public(s_BootLoaders[i][E_BOOT_NAME], "");
        return 1;
    }

    if (pending > 0)
    {
        Log_Warn("boot", "%d loaders wait on something that never finished", pending);
    }

    Boot_Finish();
    return 1;
}
