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
static Bank_SendBalanceLine(playerid,colour)
{
    new line[128];
    format(line,sizeof(line),"  You Have $%d in your account.",Bank_GetBalance(playerid));
    SendClientMessage(playerid,colour,line);
}

static bool:Bank_IsAtBank(playerid)
{
    if (Account_GetLocal(playerid) != BANK_LOCAL)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not at the Bank !");
        return false;
    }

    return true;
}

CMD:withdraw(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Bank_IsAtBank(playerid))
    {
        return 1;
    }

    new amountText[32];

    if (sscanf(params, "s[32]", amountText))
    {
        SendClientMessage(playerid, COLOR_GRAD2, "USAGE: /withdraw [amount]");
        Bank_SendBalanceLine(playerid, COLOR_GRAD3);
        return 1;
    }

    new amount = strval(amountText);

    if (amount > Bank_GetBalance(playerid) || amount < 1)
    {
        SendClientMessage(playerid, COLOR_GRAD2, "   You don't have that much !");
        return 1;
    }

    Account_SetCash(playerid, Account_GetCash(playerid) + amount);
    Bank_AddBalance(playerid, -amount);

    new line[128];
    format(line, sizeof(line), "  You Have Withdrawn $%d from your account Total: $%d ", amount, Bank_GetBalance(playerid));
    SendClientMessage(playerid, COLOR_YELLOW, line);
    return 1;
}

CMD:bank(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Bank_IsAtBank(playerid))
    {
        return 1;
    }

    new amountText[32];

    if (sscanf(params, "s[32]", amountText))
    {
        SendClientMessage(playerid, COLOR_GRAD2, "USAGE: /bank [amount]");
        Bank_SendBalanceLine(playerid, COLOR_GRAD3);
        return 1;
    }

    new amount = strval(amountText);

    if (amount > Account_GetCash(playerid) || amount < 1)
    {
        SendClientMessage(playerid, COLOR_GRAD2, "   You don't have that much");
        return 1;
    }

    Account_SetCash(playerid, Account_GetCash(playerid) - amount);

    new oldBalance = Bank_GetBalance(playerid), line[128];
    Bank_AddBalance(playerid, amount);

    SendClientMessage(playerid, COLOR_WHITE, "|___ BANK STATEMENT ___|");
    format(line, sizeof(line), "  Old Balance: $%d", oldBalance);
    SendClientMessage(playerid, COLOR_GRAD2, line);
    format(line, sizeof(line), "  Deposit: $%d", amount);
    SendClientMessage(playerid, COLOR_GRAD4, line);
    SendClientMessage(playerid, COLOR_GRAD6, "|-----------------------------------------|");
    format(line, sizeof(line), "  New Balance: $%d", Bank_GetBalance(playerid));
    SendClientMessage(playerid, COLOR_WHITE, line);
    return 1;
}

ALT:deposit=CMD:bank;

CMD:balance(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!Bank_IsAtBank(playerid))
    {
        return 1;
    }

    Bank_SendBalanceLine(playerid, COLOR_YELLOW);
    return 1;
}

CMD:transfer(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (Account_GetLevel(playerid) < BANK_TRANSFER_LEVEL)
    {
        SendClientMessage(playerid, COLOR_GRAD1, "   You must be level 3 !");
        return 1;
    }

    if (!Bank_IsAtBank(playerid))
    {
        return 1;
    }

    new targetid, amountText[32];

    if (sscanf(params, "us[32]", targetid, amountText))
    {
        SendClientMessage(playerid, COLOR_GRAD1, "USAGE: /transfer [playerid/PartOfName] [amount]");
        return 1;
    }

    new line[144];

    if (targetid == INVALID_PLAYER_ID || !Bank_IsLoaded(targetid))
    {
        new typed[MAX_PLAYER_NAME + 1];
        Economy_ReadToken(params, typed);
        format(line, sizeof(line), ECONOMY_NOT_ACTIVE_FORMAT, typed);
        SendClientMessage(playerid, COLOR_GRAD1, line);
        return 1;
    }

    new amount = strval(amountText);

    if (amount < 1 || Bank_GetBalance(playerid) < amount)
    {
        SendClientMessage(playerid, COLOR_GRAD1, "   Invalid transaction amount.");
        return 1;
    }

    new senderName[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, senderName, sizeof(senderName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    Bank_AddBalance(playerid, -amount);
    Bank_AddBalance(targetid, amount);

    format(line, sizeof(line), "   You have transferred $%d to %s's account", amount, targetName);
    PlayerPlaySound(playerid, ECONOMY_PAY_SOUND, 0.0, 0.0, 0.0);
    SendClientMessage(playerid, COLOR_GRAD1, line);
    format(line, sizeof(line), "   You have received $%d into your account from %s", amount, senderName);
    SendClientMessage(targetid, COLOR_GRAD1, line);
    format(line, sizeof(line), "%s transferred $%d to %s", senderName, amount, targetName);

    if (amount >= BANK_TRANSFER_ALERT)
    {
        Economy_AdminAlert(COLOR_YELLOW, line);
    }

    Economy_PayLog(line, true);
    PlayerPlaySound(targetid, ECONOMY_PAY_SOUND, 0.0, 0.0, 0.0);
    return 1;
}

ALT:wiretransfer=CMD:transfer;
