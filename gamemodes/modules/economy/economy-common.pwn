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
#define ECONOMY_PAY_SOUND (1052)
#define ECONOMY_ALERT_ADMIN_LEVEL (1)
#define ECONOMY_NOT_ACTIVE_FORMAT "   %s is not an active player."

forward Economy_OnPayLog(const text[]);

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
stock Economy_PayLog(const text[],bool:echo = false)
{
    pawn_call_public("Economy_OnPayLog","s",text);

    if (echo)
    {
        Log_Info("pay","%s",text);
    }
}

stock Economy_ReadToken(const params[],dest[],size = sizeof(dest))
{
    new at = 0, length = 0;

    while (params[at] != EOS && params[at] <= ' ')
    {
        at++;
    }

    while (params[at] != EOS && params[at] > ' ' && length < size - 1)
    {
        dest[length++] = params[at++];
    }

    dest[length] = EOS;
    return length;
}

stock Economy_AdminAlert(colour,const text[],level = ECONOMY_ALERT_ADMIN_LEVEL)
{
    foreach (new playerid : Player)
    {
        if (!IsPlayerNPC(playerid) && Account_GetAdminLevel(playerid) >= level)
        {
            SendClientMessage(playerid,colour,text);
        }
    }

    Log_Info("pay","%s",text);
}

stock Economy_SendNews(colour,const text[])
{
    Chat_SendOoc(colour,text);
}
