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
stock Vehicles_TimeCheckPlayer(playerid)
{
    for (new vehicleid = VEHICLE_PLANE_UNLOCK_FIRST; vehicleid <= VEHICLE_PLANE_UNLOCK_LAST; vehicleid++)
    {
        if (IsValidVehicle(vehicleid))
        {
            SetVehicleParamsForPlayer(vehicleid, playerid, 0, 0);
        }
    }

    if (!Player_IsReady(playerid))
    {
        return;
    }

    new Float:health;
    GetPlayerHealth(playerid, health);
    SetPlayerHealth(playerid, health - 1.0);

    pawn_call_public("Vehicles_OnTimeCheck", "d", playerid);

    new cash = Account_GetCash(playerid);

    if (cash < 0)
    {
        if (!g_PlayerDebtWarned[playerid])
        {
            new line[96];
            format(line, sizeof(line), "You are in debt, you have till next Time Check to get: $%d or you go to jail.", cash);
            SendClientMessage(playerid, COLOR_LIGHTRED, line);
            g_PlayerDebtWarned[playerid] = true;
        }
    }
    else
    {
        g_PlayerDebtWarned[playerid] = false;
    }
}

stock Vehicles_CarCheck()
{
    foreach (new playerid : Player)
    {
        if (!IsPlayerNPC(playerid))
        {
            Vehicles_TimeCheckPlayer(playerid);
        }
    }

    foreach (new playerid : Player)
    {
        if (!g_PlayerSeesUnlocked[playerid])
        {
            continue;
        }

        for (new vehicleid = 1; vehicleid <= MAX_VEHICLES; vehicleid++)
        {
            if (IsValidVehicle(vehicleid))
            {
                SetVehicleParamsForPlayer(vehicleid, playerid, 0, 0);
            }
        }
    }

    Vehicles_AgeAbandoned();
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
Timer_Declare(Vehicles_CarCheckTimer)
{
    Vehicles_CarCheck();
    return true;
}
