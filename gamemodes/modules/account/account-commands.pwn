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
CMD<CMD_FLAG_PRELOGIN>:login(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (Account_IsLoggedIn(playerid))
    {
        SendClientMessage(playerid, COLOR_WHITE, ACCOUNT_REPLY_LOGGED_IN);
        return 1;
    }

    new password[ACCOUNT_PASSWORD_MAX + 1];

    if (sscanf(params, "s[64]", password))
    {
        SendClientMessage(playerid, COLOR_GRAD1, "USAGE: /login [password]");
        Account_ShowAuthDialog(playerid);
        return 1;
    }

    Account_RequestLogin(playerid, password);
    return 1;
}

CMD<CMD_FLAG_PRELOGIN>:register(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (Account_CheckRegister(playerid) != ACCOUNT_ATTEMPT_STARTED)
    {
        return 1;
    }

    new password[ACCOUNT_PASSWORD_MAX + 1];

    if (sscanf(params, "s[64]", password))
    {
        SendClientMessage(playerid, COLOR_GRAD1, "USAGE: /register [password]");
        Account_ShowAuthDialog(playerid);
        return 1;
    }

    Account_RequestRegister(playerid, password);
    return 1;
}

CMD:stats(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Stats_Show(playerid, playerid);
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:logout(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Account_Logout(playerid);
    SendClientMessage(playerid, COLOR_GRAD1, "   It is now safe to quit.");
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:logoutpl(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;

    if (sscanf(params, "u", targetid))
    {
        SendClientMessage(playerid, COLOR_GRAD2, "USAGE: /logoutpl [playerid/PartOfName]");
        return 1;
    }

    if (targetid != INVALID_PLAYER_ID && IsPlayerConnected(targetid))
    {
        Account_Logout(targetid);
        SendClientMessage(playerid, COLOR_GRAD1, "   player was logged out.");
    }

    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:logoutall(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    foreach (new i : Player)
    {
        Account_Logout(i);
    }

    SendClientMessage(playerid, COLOR_GRAD1, "   All Players Logged out.");
    return 1;
}
