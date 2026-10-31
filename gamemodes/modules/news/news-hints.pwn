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
#define NEWS_HINT_X (-2050.8962)
#define NEWS_HINT_Y (460.0262)
#define NEWS_HINT_Z (35.1719)
#define NEWS_HINT_RADIUS (2.0)
#define NEWS_HINT_STYLE (3)
#define NEWS_HINT_MEMBER (9)
#define NEWS_HINT_PAPERBOY_JOB (15)

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
forward News_HintCreateGate(playerid);
forward News_HintListGate(playerid);

public News_HintCreateGate(playerid)
{
    return Factions_GetMember(playerid) == NEWS_HINT_MEMBER || Factions_GetLeader(playerid) == NEWS_HINT_MEMBER;
}

public News_HintListGate(playerid)
{
    return !News_HintCreateGate(playerid) && Jobs_GetJob(playerid) == NEWS_HINT_PAPERBOY_JOB;
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

hook OnGameModeInit()
{
    Hints_Register(NEWS_HINT_X,NEWS_HINT_Y,NEWS_HINT_Z,NEWS_HINT_RADIUS,"~w~Type ~r~/paper ~w~to create a newspaper",NEWS_HINT_STYLE,true,"News_HintCreateGate");
    Hints_Register(NEWS_HINT_X,NEWS_HINT_Y,NEWS_HINT_Z,NEWS_HINT_RADIUS,"~w~Type ~r~/papers ~w~to see all the made newspapers",NEWS_HINT_STYLE,true,"News_HintListGate");
}
