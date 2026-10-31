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
CMD:lotto(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (Lotto_GetTicket(playerid) > 0)
    {
        SendClientMessage(playerid, COLOR_GREY, "   You already have a Lottery Ticket !");
        return 1;
    }

    if (Account_GetCash(playerid) < LOTTO_TICKET_PRICE)
    {
        SendClientMessage(playerid, COLOR_GREY, "   You need $1500 for a Lottery Ticket !");
        return 1;
    }

    new numberText[32];

    if (sscanf(params, "s[32]", numberText))
    {
        SendClientMessage(playerid, COLOR_WHITE, "USAGE: /lotto [number]");
        return 1;
    }

    new number = strval(numberText);

    if (number < 1 || number > LOTTO_NUMBER_MAX)
    {
        SendClientMessage(playerid, COLOR_GREY, "   Lottery Number not below 1 or above 80 !");
        return 1;
    }

    new line[96];
    format(line, sizeof(line), "* You bought a Lottery Ticket with number: %d.", number);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, line);
    Account_SetCash(playerid, Account_GetCash(playerid) - LOTTO_TICKET_PRICE);
    Lotto_SetTicket(playerid, number);
    return 1;
}

CMD<ADMIN_LEVEL_DEVELOPER>:startlotto(cmdid, playerid, params[])
{
    #pragma unused cmdid, playerid, params

    Economy_SendNews(COLOR_WHITE, "Lottery News: We have started the Lottery Election.");

    new number = random(LOTTO_NUMBER_MAX);

    if (number < 77)
    {
        number += 3;
    }

    Lotto_Draw(number);
    return 1;
}
