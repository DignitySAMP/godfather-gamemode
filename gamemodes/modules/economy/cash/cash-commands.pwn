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
#define CASH_PAY_LEVEL (3)
#define CASH_PAY_FREE_LIMIT (1000)
#define CASH_PAY_MAX (99999)
#define CASH_PAY_ALERT (1000000)
#define CASH_PAY_RANGE (5.0)
#define CASH_EMOTE_RANGE (30.0)
#define CASH_BLOCKED_LOCAL (106)

/**
 *                                   __
 *                                  |  |
 *      _______  ______ ____    ____| $$  _______
 *     /       \|      \    \  /      $$ /       |
 *    |  $$$$$$$| $$$$$$\$$$$\|  $$$$$$$|  $$$$$$$
 *    | $$      | $$ | $$ | $$| $$  | $$ \$$    |
 *    | $$_____ | $$ | $$ | $$| $$__| $$ _\$$$$$$|
 *     \$$     \| $$ | $$ | $$ \$$    $$|       $$
 *      \$$$$$$$ \$$  \$$  \$$  \$$$$$$$ \$$$$$$$
 *
 */
CMD:pay(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid, amountText[32];

    if (sscanf(params, "us[32]", targetid, amountText))
    {
        SendClientMessage(playerid, COLOR_GRAD1, "USAGE: /pay [playerid/PartOfName] [amount]");
        return 1;
    }

    new amount = strval(amountText);

    if (amount > CASH_PAY_FREE_LIMIT && Account_GetLevel(playerid) < CASH_PAY_LEVEL)
    {
        SendClientMessage(playerid, COLOR_GRAD1, "You must be level 3 to pay over 1000");
        return 1;
    }

    if (amount < 1 || amount > CASH_PAY_MAX)
    {
        SendClientMessage(playerid, COLOR_GRAD1, "Don't go below 1, or above 99999 at once.");
        return 1;
    }

    new line[144];

    if (targetid == INVALID_PLAYER_ID || !Player_IsReady(targetid))
    {
        new typed[MAX_PLAYER_NAME + 1];
        Economy_ReadToken(params, typed);
        format(line, sizeof(line), ECONOMY_NOT_ACTIVE_FORMAT, typed);
        SendClientMessage(playerid, COLOR_GRAD1, line);
        return 1;
    }

    if (Account_GetLocal(targetid) == CASH_BLOCKED_LOCAL)
    {
        SendClientMessage(playerid, COLOR_GRAD1, "Command not allowed in this location");
        return 1;
    }

    if (!Util_IsNear(playerid, targetid, CASH_PAY_RANGE))
    {
        SendClientMessage(playerid, COLOR_GRAD1, "   You're too far away.");
        return 1;
    }

    if (Account_GetCash(playerid) < amount)
    {
        SendClientMessage(playerid, COLOR_GRAD1, "   Invalid transaction amount.");
        return 1;
    }

    new senderName[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, senderName, sizeof(senderName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    Account_SetCash(playerid, Account_GetCash(playerid) - amount);
    Account_SetCash(targetid, Account_GetCash(targetid) + amount);

    format(line, sizeof(line), "   You have sent %s(player: %d), $%d.", targetName, targetid, amount);
    PlayerPlaySound(playerid, ECONOMY_PAY_SOUND, 0.0, 0.0, 0.0);
    SendClientMessage(playerid, COLOR_GRAD1, line);
    format(line, sizeof(line), "   You have received $%d from %s(player: %d).", amount, senderName, playerid);
    SendClientMessage(targetid, COLOR_GRAD1, line);
    format(line, sizeof(line), "%s has paid $%d to %s", senderName, amount, targetName);
    Economy_PayLog(line);

    if (amount >= CASH_PAY_ALERT)
    {
        Economy_AdminAlert(COLOR_YELLOW, line);
    }

    PlayerPlaySound(targetid, ECONOMY_PAY_SOUND, 0.0, 0.0, 0.0);
    format(line, sizeof(line), "* %s takes out some cash, and hands it to %s.", senderName, targetName);
    Chat_ProxDetector(CASH_EMOTE_RANGE, playerid, line, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
    return 1;
}

CMD:charity(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new amountText[32];

    if (sscanf(params, "s[32]", amountText))
    {
        SendClientMessage(playerid, COLOR_GRAD1, "USAGE: /charity [amount]");
        return 1;
    }

    if (Account_GetLocal(playerid) == CASH_BLOCKED_LOCAL)
    {
        SendClientMessage(playerid, COLOR_GRAD1, "Command not allowed in this location");
        return 1;
    }

    new amount = strval(amountText);

    if (amount < 0)
    {
        SendClientMessage(playerid, COLOR_GRAD1, "That is not enough.");
        return 1;
    }

    if (Account_GetCash(playerid) < amount)
    {
        SendClientMessage(playerid, COLOR_GRAD1, "You don't have that much money.");
        return 1;
    }

    Account_SetCash(playerid, Account_GetCash(playerid) - amount);

    new name[MAX_PLAYER_NAME + 1], line[144];
    GetPlayerName(playerid, name, sizeof(name));
    format(line, sizeof(line), "%s Thank you for your donation of, $%d.", name, amount);
    PlayerPlaySound(playerid, ECONOMY_PAY_SOUND, 0.0, 0.0, 0.0);
    SendClientMessage(playerid, COLOR_GRAD1, line);
    Economy_PayLog(line, true);
    return 1;
}
