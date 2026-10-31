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
#define FACTION_SKIN_LIST_COUNT (52)

static bool:s_FactionSelecting[MAX_PLAYERS];
static s_FactionSelectFaction[MAX_PLAYERS];
static s_FactionSelectPlace[MAX_PLAYERS];
static s_FactionChosenSkin[MAX_PLAYERS];
static bool:s_FactionPreviewing[MAX_PLAYERS];
static Float:s_FactionPreviewPos[MAX_PLAYERS][3];
static s_FactionPreviewInterior[MAX_PLAYERS];

static const s_FactionJoinSkins[FACTION_SKIN_LIST_COUNT] =
{
    280, 281, 282, 283, 284, 285, 288, 71, 166, 295, 148,
    286, 164, 163,
    287, 285,
    70, 274, 275, 276, 277, 278, 279,
    258, 127, 126, 125, 124, 113, 111, 98,
    120, 121, 122, 123, 169, 186, 228,
    127, 165, 186, 93, 141,
    148, 188, 187,
    255, 253,
    59, 60, 76, 150
};

static const s_FactionJoinFirst[FACTION_COUNT] =
{
    0, 0, 11, 14, 16, 23, 31, 0, 38, 43, 46, 48
};

static const s_FactionJoinCount[FACTION_COUNT] =
{
    0, 11, 3, 2, 7, 8, 7, 0, 5, 3, 2, 4
};

static const s_FactionInviteTeams[FACTION_COUNT] =
{
    0, 2, 2, 2, 1, 5, 5, 0, 10, 12, 12, 12
};

static const s_FactionInviteRuntimeTeams[FACTION_COUNT] =
{
    0, 2, 2, 2, 1, 5, 5, 0, 12, 12, 12, 12
};

static const s_FactionChosenSkins[FACTION_COUNT] =
{
    0, 280, 286, 287, 70, 258, 120, 0, 127, 148, 255, 59
};

static const s_FactionPreviewSkins[FACTION_COUNT] =
{
    0, 280, 286, 287, 70, 120, 258, 0, 127, 148, 255, 59
};

static const s_FactionNames[FACTION_COUNT][20] =
{
    "", "Police Force", "FBI/ATF", "National Guard", "Firemen/Ambulance", "La Cosa Nostra", "Yakuza", "", "Hitman Agency", "CNN Studio", "Taxi Cab Company", "School Instructors"
};

static const Float:s_FactionInviteSpawns[10][4] =
{
    {-1976.5912, 166.1818, 36.9623, 272.6393},
    {-1975.8610, 162.1945, 36.9623, 272.0126},
    {-1975.7461, 157.5404, 36.9623, 276.1093},
    {-1975.2136, 151.4920, 36.9623, 268.2993},
    {-1974.9963, 145.3430, 36.9623, 269.2628},
    {-1975.5842, 140.8170, 36.9623, 269.8895},
    {-1975.7874, 134.0368, 36.9623, 271.7696},
    {-1975.1681, 129.0926, 36.9623, 270.8531},
    {-1975.9069, 121.4700, 36.9623, 270.5631},
    {-1975.3311, 112.7078, 36.9623, 267.7665}
};

forward Factions_ChatCharSelect(playerid,const text[]);

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
static Factions_ResetSelect(playerid)
{
    s_FactionSelecting[playerid] = false;
    s_FactionSelectFaction[playerid] = 0;
    s_FactionSelectPlace[playerid] = 0;
    s_FactionChosenSkin[playerid] = 0;
    s_FactionPreviewing[playerid] = false;
}

stock Factions_GetInviteName(faction,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (faction >= 1 && faction < FACTION_COUNT)
    {
        strcopy(dest,s_FactionNames[faction],size);
    }
}

stock Factions_GetInviteTeam(faction)
{
    if (faction < 1 || faction >= FACTION_COUNT)
    {
        return 0;
    }

    return s_FactionInviteTeams[faction];
}

stock Factions_GetInviteRuntimeTeam(faction)
{
    if (faction < 1 || faction >= FACTION_COUNT)
    {
        return 0;
    }

    return s_FactionInviteRuntimeTeams[faction];
}

stock Factions_GetChosenSkinFor(faction)
{
    if (faction < 1 || faction >= FACTION_COUNT)
    {
        return 0;
    }

    return s_FactionChosenSkins[faction];
}

stock Factions_GetPreviewSkinFor(faction)
{
    if (faction < 1 || faction >= FACTION_COUNT)
    {
        return 0;
    }

    return s_FactionPreviewSkins[faction];
}

stock Factions_SetChosenSkin(playerid,skin)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_FactionChosenSkin[playerid] = skin;
    }
}

stock Factions_BeginCharSelect(playerid,bool:remember = false)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    if (remember)
    {
        GetPlayerPos(playerid,s_FactionPreviewPos[playerid][0],s_FactionPreviewPos[playerid][1],s_FactionPreviewPos[playerid][2]);
        s_FactionPreviewInterior[playerid] = GetPlayerInterior(playerid);
        s_FactionPreviewing[playerid] = true;
    }

    new pick = random(sizeof(s_FactionInviteSpawns)), Float:x = s_FactionInviteSpawns[pick][0], Float:y = s_FactionInviteSpawns[pick][1], Float:z = s_FactionInviteSpawns[pick][2];
    SetPlayerInterior(playerid,0);
    SetPlayerPos(playerid,x,y,z);
    SetPlayerFacingAngle(playerid,s_FactionInviteSpawns[pick][3]);
    SetPlayerCameraPos(playerid,x + 3.0,y,z);
    SetPlayerCameraLookAt(playerid,x,y,z);
    TogglePlayerControllable(playerid,false);
    s_FactionSelecting[playerid] = true;
    s_FactionSelectFaction[playerid] = Factions_GetMember(playerid);
    s_FactionSelectPlace[playerid] = 1;
    Account_SetModel(playerid,s_FactionChosenSkin[playerid]);
    Account_SetChar(playerid,s_FactionChosenSkin[playerid]);
    SendClientMessage(playerid,COLOR_LIGHTRED,"* Use 'next' to Select the char you want to use.");
    SendClientMessage(playerid,COLOR_LIGHTRED,"* If you've found the Char you want to use, type 'done'.");
}

static Factions_NextSkin(playerid)
{
    new faction = s_FactionSelectFaction[playerid];

    if (faction < 1 || faction >= FACTION_COUNT || s_FactionJoinCount[faction] == 0)
    {
        return;
    }

    new place = s_FactionSelectPlace[playerid], skin = s_FactionJoinSkins[s_FactionJoinFirst[faction] + place - 1];
    SetPlayerSkin(playerid,skin);
    s_FactionChosenSkin[playerid] = skin;
    s_FactionSelectPlace[playerid] = place >= s_FactionJoinCount[faction] ? 1 : place + 1;
}

static Factions_FinishSelect(playerid)
{
    if (s_FactionPreviewing[playerid])
    {
        SetPlayerInterior(playerid,s_FactionPreviewInterior[playerid]);
        SetPlayerPos(playerid,s_FactionPreviewPos[playerid][0],s_FactionPreviewPos[playerid][1],s_FactionPreviewPos[playerid][2]);
        s_FactionPreviewing[playerid] = false;
        return;
    }

    Account_SetModel(playerid,s_FactionChosenSkin[playerid]);
    Account_SetChar(playerid,s_FactionChosenSkin[playerid]);
    Factions_SetTeam(playerid,Account_GetTeam(playerid));
    Factions_ApplyTeamColour(playerid);
    Factions_OnTeamChangedNotify(playerid);
    Spawn_Begin(playerid);
    s_FactionSelectPlace[playerid] = 0;
    s_FactionSelectFaction[playerid] = 0;
    s_FactionSelecting[playerid] = false;
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
public Factions_ChatCharSelect(playerid,const text[])
{
    if (!Util_IsValidPlayer(playerid) || !s_FactionSelecting[playerid])
    {
        return 0;
    }

    new word[16];
    sscanf(text,"s[16]",word);

    if (!strcmp(word,"next",true))
    {
        Factions_NextSkin(playerid);
        return 1;
    }

    if (!strcmp(word,"done",true))
    {
        Factions_FinishSelect(playerid);
        return 1;
    }

    SendClientMessage(playerid,COLOR_LIGHTBLUE,"* Use 'next', or 'done'.");
    return 1;
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
    Factions_ResetSelect(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Factions_ResetSelect(playerid);
}

hook Account_OnLogout(playerid,accountid)
{
    Factions_ResetSelect(playerid);
}
