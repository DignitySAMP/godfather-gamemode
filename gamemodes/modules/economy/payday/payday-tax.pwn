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
#define PAYDAY_TAX_DEFAULT_POOL (0)
#define PAYDAY_TAX_DEFAULT_VALUE (0)

static s_PaydayTaxPool = PAYDAY_TAX_DEFAULT_POOL;
static s_PaydayTaxValue = PAYDAY_TAX_DEFAULT_VALUE;

forward Task:Payday_LoadTax();

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
static Payday_WriteTax()
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE payday_state SET tax_pool = %d, tax_value = %d WHERE id = 1",s_PaydayTaxPool,s_PaydayTaxValue));
}

stock Payday_GetTaxPool()
{
    return s_PaydayTaxPool;
}

stock Payday_SetTaxPool(amount)
{
    s_PaydayTaxPool = amount;
    Payday_WriteTax();
}

stock Payday_AddTaxPool(amount)
{
    s_PaydayTaxPool += amount;
    Payday_WriteTax();
    return s_PaydayTaxPool;
}

stock Payday_GetTaxValue()
{
    return s_PaydayTaxValue;
}

stock Payday_SetTaxValue(amount)
{
    s_PaydayTaxValue = amount;
    Payday_WriteTax();
}

#pragma warning push
#pragma warning disable 204
async Task:Payday_LoadTax()
{
    await mysql_aquery_s(g_Mysql,str_new("SELECT tax_pool, tax_value FROM payday_state WHERE id = 1 LIMIT 1"),false);

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"tax_pool",s_PaydayTaxPool);
        cache_get_value_name_int(0,"tax_value",s_PaydayTaxValue);
    }
    else
    {
        s_PaydayTaxPool = PAYDAY_TAX_DEFAULT_POOL;
        s_PaydayTaxValue = PAYDAY_TAX_DEFAULT_VALUE;
    }

    return async 1;
}
#pragma warning pop
