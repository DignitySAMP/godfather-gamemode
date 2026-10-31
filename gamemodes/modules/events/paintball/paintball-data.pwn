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
#define PAINTBALL_WEAPON (29)
#define PAINTBALL_AMMO (999)
#define PAINTBALL_START_SOUND (1057)
#define PAINTBALL_SPAWN_COUNT (7)
#define PAINTBALL_PREPARE_MS (15000)
#define PAINTBALL_START_MS (20000)
#define PAINTBALL_ROUND_MS (240000)
#define PAINTBALL_TICK_MS (1000)
#define PAINTBALL_LINE_LEN (144)

static const Float:s_PaintballSpawns[PAINTBALL_SPAWN_COUNT][3] =
{
    {-394.8027, 2232.2317, 42.4297},
    {-430.8412, 2240.5371, 42.9834},
    {-369.2361, 2248.3127, 42.4844},
    {-350.8910, 2218.0215, 42.4912},
    {-384.0544, 2206.2908, 42.4235},
    {-395.7100, 2214.9480, 42.4297},
    {-445.3718, 2222.5481, 42.4297}
};

static bool:s_PaintballActive[MAX_PLAYERS];
static s_PaintballKills[MAX_PLAYERS];
static s_PaintballPlayers;
static bool:s_PaintballRound;
static bool:s_PaintballStarting;
static bool:s_PaintballAnnounced;
static s_PaintballWinner = INVALID_PLAYER_ID;
static s_PaintballWinnerKills;
static s_PaintballPrepareMs = PAINTBALL_PREPARE_MS;
static s_PaintballStartMs = PAINTBALL_START_MS;
static s_PaintballRoundMs = PAINTBALL_ROUND_MS;
static bool:s_PaintballTickEnabled = true;

forward Paintball_Prepare();
forward Paintball_Start();
forward Paintball_End();
forward Paintball_GiveWeapons(playerid);
forward Paintball_IsPlaying(playerid);

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
stock bool:Paintball_IsPaintballing(playerid)
{
    return Util_IsValidPlayer(playerid) && s_PaintballActive[playerid];
}

stock Paintball_Reset(playerid)
{
    s_PaintballActive[playerid] = false;
    s_PaintballKills[playerid] = 0;
}

stock Paintball_ResetRound()
{
    s_PaintballPlayers = 0;
    s_PaintballRound = false;
    s_PaintballStarting = false;
    s_PaintballAnnounced = false;
    s_PaintballWinner = INVALID_PLAYER_ID;
    s_PaintballWinnerKills = 0;
}

stock Paintball_GetSpawn(index,&Float:x,&Float:y,&Float:z)
{
    x = s_PaintballSpawns[index][0];
    y = s_PaintballSpawns[index][1];
    z = s_PaintballSpawns[index][2];
}

stock Paintball_PickSpawn(&Float:x,&Float:y,&Float:z)
{
    new index = random(PAINTBALL_SPAWN_COUNT);
    Paintball_GetSpawn(index,x,y,z);
    return index;
}

stock Paintball_Join(playerid)
{
    new Float:x, Float:y, Float:z;
    s_PaintballPlayers++;
    s_PaintballActive[playerid] = true;
    Paintball_PickSpawn(x,y,z);
    SetPlayerPos(playerid,x,y,z);
    TogglePlayerControllable(playerid,false);
}

stock Paintball_Leave(playerid)
{
    if (s_PaintballActive[playerid])
    {
        s_PaintballPlayers--;
    }

    Paintball_Reset(playerid);
}

stock Paintball_CountKill(killerid)
{
    if (!Util_IsValidPlayer(killerid))
    {
        return;
    }

    s_PaintballKills[killerid]++;

    if (s_PaintballKills[killerid] > s_PaintballWinnerKills)
    {
        new killer[MAX_PLAYER_NAME + 1], line[PAINTBALL_LINE_LEN];
        s_PaintballWinner = killerid;
        s_PaintballWinnerKills = s_PaintballKills[killerid];
        GetPlayerName(killerid,killer,sizeof(killer));
        format(line,sizeof(line),"* %s is in the lead with %d Kills.",killer,s_PaintballWinnerKills);

        for (new i = 0;i < MAX_PLAYERS;i++)
        {
            if (IsPlayerConnected(i) && s_PaintballActive[i])
            {
                SendClientMessage(i,COLOR_WHITE,line);
            }
        }
    }
}

stock Paintball_ArmSpawned(playerid)
{
    if (s_PaintballActive[playerid])
    {
        SetTimerEx("Paintball_GiveWeapons",0,false,"d",playerid);
    }
}

stock Paintball_Step()
{
    if (s_PaintballPlayers >= 2 && !s_PaintballRound && !s_PaintballStarting)
    {
        s_PaintballStarting = true;
        SetTimer("Paintball_Prepare",s_PaintballPrepareMs,false);
    }

    if (!s_PaintballStarting || s_PaintballAnnounced)
    {
        return;
    }

    s_PaintballAnnounced = true;

    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        if (IsPlayerConnected(i) && s_PaintballActive[i])
        {
            SendClientMessage(i,COLOR_YELLOW,"Paintball Match will be announced in 15 seconds (For getting more Paintball players).");
        }
    }
}

Timer_Declare(Paintball_Ticker)
{
    if (s_PaintballTickEnabled)
    {
        Paintball_Step();
    }

    return true;
}

stock Paintball_StartTicker()
{
    Timer_Start(Paintball_Ticker,PAINTBALL_TICK_MS);
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
public Paintball_Prepare()
{
    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        if (IsPlayerConnected(i) && s_PaintballActive[i])
        {
            SendClientMessage(i,COLOR_YELLOW,"Paintball Match will start in 20 seconds.");
        }
    }

    SetTimer("Paintball_Start",s_PaintballStartMs,false);
    return 1;
}

public Paintball_Start()
{
    s_PaintballRound = true;
    s_PaintballStarting = false;
    s_PaintballWinner = INVALID_PLAYER_ID;
    s_PaintballWinnerKills = 0;

    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        if (IsPlayerConnected(i) && s_PaintballActive[i])
        {
            ResetPlayerWeapons(i);
            GivePlayerWeapon(i,WEAPON:PAINTBALL_WEAPON,PAINTBALL_AMMO);
            TogglePlayerControllable(i,true);
            SendClientMessage(i,COLOR_YELLOW,"Paintball Match started, 4 minutes left.");
            PlayerPlaySound(i,PAINTBALL_START_SOUND,0.0,0.0,0.0);
        }
    }

    SetTimer("Paintball_End",s_PaintballRoundMs,false);
    return 1;
}

public Paintball_End()
{
    new Float:x, Float:y, Float:z, line[PAINTBALL_LINE_LEN], name[MAX_PLAYER_NAME + 1];
    Business_GetEntrance(Business_MakeSpecialKey(SBIZ_PAINTBALL),x,y,z);

    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        if (IsPlayerConnected(i) && s_PaintballActive[i])
        {
            if (Util_IsValidPlayer(s_PaintballWinner))
            {
                GetPlayerName(s_PaintballWinner,name,sizeof(name));
                format(line,sizeof(line),"** %s won the Paintball Match with %d kills **",name,s_PaintballWinnerKills);
                SendClientMessage(i,COLOR_WHITE,line);
            }

            ResetPlayerWeapons(i);
            s_PaintballActive[i] = false;
            s_PaintballPlayers--;
            SetPlayerPos(i,x,y,z);
        }
    }

    s_PaintballAnnounced = false;
    s_PaintballRound = false;
    return 1;
}

public Paintball_GiveWeapons(playerid)
{
    if (IsPlayerConnected(playerid) && s_PaintballActive[playerid])
    {
        ResetPlayerWeapons(playerid);
        GivePlayerWeapon(playerid,WEAPON:PAINTBALL_WEAPON,PAINTBALL_AMMO);
    }

    return 1;
}

public Paintball_IsPlaying(playerid)
{
    return Paintball_IsPaintballing(playerid) ? 1 : 0;
}
