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
#define MISC_FRISK_BROADCAST_RANGE (30.0)
#define MISC_FRISK_ITEM_DRUGS (0)
#define MISC_FRISK_ITEM_MATERIALS (1)
#define MISC_FRISK_ITEM_FISHES (2)
#define MISC_FRISK_ITEM_PHONEBOOK (3)
#define MISC_FRISK_ITEM_CDPLAYER (4)
#define MISC_FRISK_ITEM_COUNT (5)

static bool:s_MiscFriskHas[MISC_FRISK_ITEM_COUNT];

static const s_MiscFriskLabels[MISC_FRISK_ITEM_COUNT][16] =
{
    "| Drugs.",
    "| Materials.",
    "| Fishes.",
    "| Phone Book.",
    "| CD-Player."
};

forward Frisk_OnBuild(playerid,targetid);

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
stock Misc_SetFriskItem(item,bool:isCarried)
{
    if (item < 0 || item >= MISC_FRISK_ITEM_COUNT)
    {
        return;
    }

    s_MiscFriskHas[item] = isCarried;
}

stock Misc_ShowFrisk(playerid,targetid)
{
    for (new i = 0;i < MISC_FRISK_ITEM_COUNT;i++)
    {
        s_MiscFriskHas[i] = false;
    }

    pawn_call_public("Frisk_OnBuild","dd",playerid,targetid);

    new line[128], name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));

    format(line,sizeof(line),"|__________ Items with %s __________|",targetName);
    SendClientMessage(playerid,COLOR_WHITE,line);

    for (new i = 0;i < MISC_FRISK_ITEM_COUNT;i++)
    {
        if (s_MiscFriskHas[i])
        {
            strcopy(line,s_MiscFriskLabels[i]);
        }
        else
        {
            strcopy(line,"| Empty Pocket.");
        }

        SendClientMessage(playerid,COLOR_GREY,line);
    }

    format(line,sizeof(line),"* %s has frisked %s for any illegal items.",name,targetName);
    Chat_ProxDetector(MISC_FRISK_BROADCAST_RANGE,playerid,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
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
public Frisk_OnBuild(playerid,targetid)
{
    return 1;
}
