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
#define LOTTO_NEW_JACKPOT_RANGE (125000)
#define LOTTO_NEW_JACKPOT_BASE (15789)
#define LOTTO_RAISE_RANGE (15000)
#define LOTTO_RAISE_BASE (2158)

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
stock Lotto_Draw(number)
{
    new bool:jackpotFallen = false, line[144], jackpot = Lotto_GetJackpot();

    format(line,sizeof(line),"Lottery News: Today the Winning Number has fallen on: %d.",number);
    Economy_SendNews(COLOR_WHITE,line);

    foreach (new playerid : Player)
    {
        if (IsPlayerNPC(playerid) || !Lotto_IsLoaded(playerid))
        {
            continue;
        }

        new ticket = Lotto_GetTicket(playerid);

        if (ticket > 0)
        {
            if (ticket == number)
            {
                new name[MAX_PLAYER_NAME + 1];
                jackpotFallen = true;
                GetPlayerName(playerid,name,sizeof(name));
                format(line,sizeof(line),"Lottery News: %s has won the Jackpot of $%d with his Lottery Ticket.",name,jackpot);
                Economy_SendNews(COLOR_WHITE,line);
                format(line,sizeof(line),"* You have Won $%d with your Lottery Ticket.",jackpot);
                SendClientMessage(playerid,COLOR_YELLOW,line);
                Account_SetCash(playerid,Account_GetCash(playerid) + jackpot);
            }
            else
            {
                SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You haven't won with your Lottery Ticket this time.");
            }

            Lotto_SetTicket(playerid,0);
        }
    }

    if (jackpotFallen)
    {
        Lotto_SetJackpot(random(LOTTO_NEW_JACKPOT_RANGE) + LOTTO_NEW_JACKPOT_BASE);
        format(line,sizeof(line),"Lottery News: The new Jackpot has been started with $%d.",Lotto_GetJackpot());
    }
    else
    {
        Lotto_SetJackpot(Lotto_GetJackpot() + random(LOTTO_RAISE_RANGE) + LOTTO_RAISE_BASE);
        format(line,sizeof(line),"Lottery News: The Jackpot has been raised to $%d.",Lotto_GetJackpot());
    }

    Economy_SendNews(COLOR_WHITE,line);
}
