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
#define KARTING_PREPARE_MS (15000)
#define KARTING_START_MS (20000)
#define KARTING_ROUND_MS (240000)
#define KARTING_TICK_MS (1000)
#define KARTING_START_SOUND (1057)
#define KARTING_RADIUS (8.0)
#define KARTING_LINE_LEN (144)
#define KARTING_STAGE_NONE (0)
#define KARTING_STAGE_WAIT (9)
#define KARTING_STAGE_FIRST (10)
#define KARTING_STAGE_FINISH (20)
#define KARTING_STAGE_POINTS (10)

static const Float:s_KartingLine[3] = {2308.3540, -2354.0039, 12.6842};

static const Float:s_KartingPoints[KARTING_STAGE_POINTS][3] =
{
    {2258.7874, -2402.9712, 12.7035},
    {2225.8755, -2461.3875, 12.7190},
    {2276.9983, -2662.8328, 12.8580},
    {2449.1399, -2663.0562, 12.8138},
    {2566.9814, -2504.5686, 12.7692},
    {2719.0520, -2503.5962, 12.7706},
    {2720.7881, -2405.6589, 12.7441},
    {2571.5195, -2401.1531, 12.7528},
    {2406.6995, -2423.1182, 12.6641},
    {2322.9194, -2341.5715, 12.6664}
};

static bool:s_KartingJoined[MAX_PLAYERS];
static bool:s_KartingInKart[MAX_PLAYERS];
static s_KartingStage[MAX_PLAYERS];
static s_KartingPlayers;
static bool:s_KartingRound;
static bool:s_KartingStarting;
static bool:s_KartingEnding;
static bool:s_KartingAnnounced;
static s_KartingFirst = INVALID_PLAYER_ID;
static s_KartingSecond = INVALID_PLAYER_ID;
static s_KartingThird = INVALID_PLAYER_ID;
static s_KartingPrepareMs = KARTING_PREPARE_MS;
static s_KartingStartMs = KARTING_START_MS;
static s_KartingRoundMs = KARTING_ROUND_MS;
static bool:s_KartingTickEnabled = true;

forward Karting_Prepare();
forward Karting_Start();
forward Karting_End();

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
stock bool:Karting_IsJoined(playerid)
{
    return Util_IsValidPlayer(playerid) && s_KartingJoined[playerid];
}

stock bool:Karting_IsRacer(playerid)
{
    return Karting_IsJoined(playerid) && s_KartingInKart[playerid];
}

stock Karting_GetStage(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_KartingStage[playerid] : KARTING_STAGE_NONE;
}

stock Karting_Reset(playerid)
{
    s_KartingJoined[playerid] = false;
    s_KartingInKart[playerid] = false;
    s_KartingStage[playerid] = KARTING_STAGE_NONE;
}

stock Karting_ResetRound()
{
    s_KartingPlayers = 0;
    s_KartingRound = false;
    s_KartingStarting = false;
    s_KartingEnding = false;
    s_KartingAnnounced = false;
    s_KartingFirst = INVALID_PLAYER_ID;
    s_KartingSecond = INVALID_PLAYER_ID;
    s_KartingThird = INVALID_PLAYER_ID;
}

stock Karting_Join(playerid)
{
    s_KartingJoined[playerid] = true;
}

stock Karting_EnterKart(playerid)
{
    if (s_KartingJoined[playerid] && !s_KartingInKart[playerid])
    {
        s_KartingInKart[playerid] = true;
        s_KartingPlayers++;
    }
}

stock Karting_LeaveKart(playerid)
{
    if (s_KartingJoined[playerid] && s_KartingInKart[playerid])
    {
        s_KartingInKart[playerid] = false;
        s_KartingPlayers--;
    }
}

stock Karting_Leave(playerid)
{
    if (s_KartingJoined[playerid] && s_KartingInKart[playerid])
    {
        s_KartingPlayers--;
    }

    Karting_Reset(playerid);
}

static Karting_ShowLine(playerid)
{
    SetPlayerCheckpoint(playerid,s_KartingLine[0],s_KartingLine[1],s_KartingLine[2],KARTING_RADIUS);
}

static Karting_Tell(colour,const text[])
{
    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        if (IsPlayerConnected(i) && Karting_IsRacer(i))
        {
            SendClientMessage(i,colour,text);
        }
    }
}

static Karting_Finish(playerid)
{
    new name[MAX_PLAYER_NAME + 1], line[KARTING_LINE_LEN];
    s_KartingStage[playerid] = KARTING_STAGE_NONE;
    DisablePlayerCheckpoint(playerid);
    GetPlayerName(playerid,name,sizeof(name));

    if (s_KartingFirst == INVALID_PLAYER_ID)
    {
        s_KartingFirst = playerid;
        format(line,sizeof(line),"* %s finished First in the Kart Race.",name);
        Karting_Tell(COLOR_WHITE,line);
    }
    else if (s_KartingSecond == INVALID_PLAYER_ID)
    {
        s_KartingSecond = playerid;
        format(line,sizeof(line),"* %s finished Second in the Kart Race.",name);
        Karting_Tell(COLOR_WHITE,line);
    }
    else if (s_KartingThird == INVALID_PLAYER_ID)
    {
        s_KartingThird = playerid;
        format(line,sizeof(line),"* %s finished Third in the Kart Race.",name);

        for (new i = 0;i < MAX_PLAYERS;i++)
        {
            if (IsPlayerConnected(i) && Karting_IsRacer(i))
            {
                SendClientMessage(i,COLOR_WHITE,line);
                SendClientMessage(i,COLOR_WHITE,"** Karting Race Over **");
                s_KartingStage[i] = KARTING_STAGE_NONE;
                DisablePlayerCheckpoint(i);
            }
        }
    }
}

stock Karting_ReachCheckpoint(playerid)
{
    new stage = s_KartingStage[playerid];

    if (stage == KARTING_STAGE_WAIT)
    {
        GameTextForPlayer(playerid,"~r~Wait here for more Kart Racers",4000,3);
        DisablePlayerCheckpoint(playerid);
        return true;
    }

    if (stage >= KARTING_STAGE_FIRST && stage < KARTING_STAGE_FINISH)
    {
        new point = stage - KARTING_STAGE_FIRST;
        s_KartingStage[playerid] = stage + 1;
        DisablePlayerCheckpoint(playerid);
        SetPlayerCheckpoint(playerid,s_KartingPoints[point][0],s_KartingPoints[point][1],s_KartingPoints[point][2],KARTING_RADIUS);
        return true;
    }

    if (stage == KARTING_STAGE_FINISH)
    {
        Karting_Finish(playerid);
        return true;
    }

    return false;
}

stock Karting_Step()
{
    if (s_KartingPlayers >= 2 && !s_KartingRound && !s_KartingStarting)
    {
        s_KartingStarting = true;
        SetTimer("Karting_Prepare",s_KartingPrepareMs,false);
    }

    if (s_KartingRound && s_KartingPlayers < 2)
    {
        s_KartingStarting = false;
        s_KartingRound = false;
        s_KartingEnding = true;
    }

    new bool:announce = s_KartingStarting && !s_KartingAnnounced;

    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        if (!IsPlayerConnected(i))
        {
            continue;
        }

        if (announce && Karting_IsRacer(i))
        {
            SendClientMessage(i,COLOR_YELLOW,"Karting Race will be announced in 15 seconds (For getting more Kart Racers).");
        }

        if (s_KartingEnding && Karting_IsRacer(i))
        {
            DisablePlayerCheckpoint(i);
            s_KartingStage[i] = KARTING_STAGE_NONE;
        }
    }

    if (announce)
    {
        s_KartingAnnounced = true;
    }
}

Timer_Declare(Karting_Ticker)
{
    if (s_KartingTickEnabled)
    {
        Karting_Step();
    }

    return true;
}

stock Karting_StartTicker()
{
    Timer_Start(Karting_Ticker,KARTING_TICK_MS);
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
public Karting_Prepare()
{
    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        if (IsPlayerConnected(i) && Karting_IsRacer(i))
        {
            s_KartingStage[i] = KARTING_STAGE_WAIT;
            Karting_ShowLine(i);
            SendClientMessage(i,COLOR_YELLOW,"Kart Race will start in 20 seconds, go to the starting line.");
        }
    }

    SetTimer("Karting_Start",s_KartingStartMs,false);
    return 1;
}

public Karting_Start()
{
    s_KartingRound = true;
    s_KartingStarting = false;
    s_KartingEnding = false;
    s_KartingFirst = INVALID_PLAYER_ID;
    s_KartingSecond = INVALID_PLAYER_ID;
    s_KartingThird = INVALID_PLAYER_ID;

    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        if (IsPlayerConnected(i) && Karting_IsRacer(i))
        {
            s_KartingStage[i] = KARTING_STAGE_FIRST;
            SendClientMessage(i,COLOR_YELLOW,"Green light, go go go !");
            PlayerPlaySound(i,KARTING_START_SOUND,0.0,0.0,0.0);
            Karting_ShowLine(i);
        }
    }

    SetTimer("Karting_End",s_KartingRoundMs,false);
    return 1;
}

public Karting_End()
{
    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        if (IsPlayerConnected(i) && Karting_IsRacer(i))
        {
            s_KartingStage[i] = KARTING_STAGE_NONE;
            DisablePlayerCheckpoint(i);
        }
    }

    s_KartingAnnounced = false;
    s_KartingRound = false;
    return 1;
}
