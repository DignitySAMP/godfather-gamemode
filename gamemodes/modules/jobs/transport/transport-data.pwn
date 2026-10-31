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
#define TRANSPORT_TAXI (0)
#define TRANSPORT_BUS (1)
#define TRANSPORT_KINDS (2)
#define TRANSPORT_LINE_LEN (144)
#define TRANSPORT_TAXI_FARE_MAX (999)
#define TRANSPORT_BUS_FARE_MAX (99999)
#define TRANSPORT_METER_SECONDS (16)
#define TRANSPORT_METER_MS (15000)
#define TRANSPORT_CHECKPOINT_SIZE (5.0)

new g_TransportDuty[MAX_PLAYERS];
new g_TransportValue[MAX_PLAYERS];
new g_TransportMoney[MAX_PLAYERS];
new g_TransportTime[MAX_PLAYERS];
new g_TransportCost[MAX_PLAYERS];
new g_TransportPaid[MAX_PLAYERS];
new g_TransportDriver[MAX_PLAYERS];
new g_TransportDrivers[TRANSPORT_KINDS];
new g_TransportCaller[TRANSPORT_KINDS] = {OFFER_NONE, OFFER_NONE};
new g_TransportCallTime[TRANSPORT_KINDS][MAX_PLAYERS];
new g_TransportAccepted[TRANSPORT_KINDS][MAX_PLAYERS];

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
stock Transport_Reset(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return;
    }

    g_TransportDuty[playerid] = 0;
    g_TransportValue[playerid] = 0;
    g_TransportMoney[playerid] = 0;
    g_TransportTime[playerid] = 0;
    g_TransportCost[playerid] = 0;
    g_TransportPaid[playerid] = 0;
    g_TransportDriver[playerid] = OFFER_NONE;

    for (new kind = 0;kind < TRANSPORT_KINDS;kind++)
    {
        g_TransportCallTime[kind][playerid] = 0;
        g_TransportAccepted[kind][playerid] = OFFER_NONE;
    }
}

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

hook OnPlayerConnect(playerid)
{
    Transport_Reset(playerid);
}
