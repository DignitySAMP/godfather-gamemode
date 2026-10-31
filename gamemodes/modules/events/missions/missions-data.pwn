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
#define MISSIONS_LOADER "Missions"
#define MISSIONS_TEXTS (18)
#define MISSIONS_GAME_TEXTS (6)
#define MISSIONS_POINTS (6)
#define MISSIONS_LINE_LEN (128)
#define MISSIONS_INPUT_LEN (64)
#define MISSIONS_NAME_LEN (32)
#define MISSIONS_MAKER_LEN (MAX_PLAYER_NAME + 1)
#define MISSIONS_MESSAGE_LEN (192)
#define MISSIONS_MAX_REWARD (50000)
#define MISSIONS_BOARD_X (1381.0413)
#define MISSIONS_BOARD_Y (-1088.8511)
#define MISSIONS_BOARD_Z (27.3906)
#define MISSIONS_BOARD_RADIUS (3.0)
#define MISSIONS_HINT_RADIUS (2.0)
#define MISSIONS_CHECKPOINT_RADIUS (8.0)
#define MISSIONS_NEAR_RADIUS (10.0)
#define MISSIONS_GAME_TEXT_MS (8000)
#define MISSIONS_GAME_TEXT_STYLE (3)
#define MISSIONS_SLOT_MAKER (0)
#define MISSIONS_SLOT_PLAY (1)
#define MISSIONS_SLOTS (2)

static s_MissionTitle[MISSIONS_SLOTS][MISSIONS_LINE_LEN];
static s_MissionText[MISSIONS_SLOTS][MISSIONS_TEXTS][MISSIONS_LINE_LEN];
static s_MissionGameText[MISSIONS_SLOTS][MISSIONS_GAME_TEXTS][MISSIONS_LINE_LEN];
static Float:s_MissionPoint[MISSIONS_SLOTS][MISSIONS_POINTS][3];
static s_MissionReward[MISSIONS_SLOTS];
static s_MissionToggle[MISSIONS_SLOTS];
static s_MissionPlayMaker[MISSIONS_MAKER_LEN];
static s_MissionPlayNumber;
static s_MissionPlayable;

static s_MissionOn[MAX_PLAYERS];
static s_MissionStage[MAX_PLAYERS];
static s_MissionDone[MAX_PLAYERS];
static bool:s_MissionLoaded[MAX_PLAYERS];

forward Missions_LoadStart(playerid,accountid,token);
forward Missions_PredicateOnMission(playerid);

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
stock bool:Missions_IsOnMission(playerid)
{
    return Util_IsValidPlayer(playerid) && s_MissionOn[playerid] > 0;
}

stock Missions_GetCompleted(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_MissionDone[playerid] : 0;
}

stock Missions_GetPlayable()
{
    return s_MissionPlayable;
}

stock Missions_SetTitle(const text[])
{
    strcopy(s_MissionTitle[MISSIONS_SLOT_MAKER],text,MISSIONS_LINE_LEN);
}

stock Missions_SetText(line,const text[])
{
    strcopy(s_MissionText[MISSIONS_SLOT_MAKER][line],text,MISSIONS_LINE_LEN);
}

stock Missions_SetGameText(line,const text[])
{
    strcopy(s_MissionGameText[MISSIONS_SLOT_MAKER][line],text,MISSIONS_LINE_LEN);
}

stock Missions_SetPoint(point,Float:x,Float:y,Float:z)
{
    s_MissionPoint[MISSIONS_SLOT_MAKER][point][0] = x;
    s_MissionPoint[MISSIONS_SLOT_MAKER][point][1] = y;
    s_MissionPoint[MISSIONS_SLOT_MAKER][point][2] = z;
}

stock Missions_SetReward(reward)
{
    s_MissionReward[MISSIONS_SLOT_MAKER] = reward;
}

stock Missions_SetToggle(toggle)
{
    s_MissionToggle[MISSIONS_SLOT_MAKER] = toggle;
}

stock Missions_ReadToken(const text[],&at,dest[],size = sizeof(dest))
{
    while (text[at] != EOS && text[at] <= ' ')
    {
        at++;
    }

    new length = 0;

    while (text[at] != EOS && text[at] > ' ')
    {
        if (length < size - 1)
        {
            dest[length++] = text[at];
        }

        at++;
    }

    dest[length] = EOS;
    return length > 0;
}

stock Missions_ReadRest(const text[],&at,dest[],size = MISSIONS_INPUT_LEN)
{
    while (text[at] != EOS && text[at] <= ' ')
    {
        at++;
    }

    new length = 0;

    while (text[at] != EOS && length < size - 1)
    {
        dest[length++] = text[at];
        at++;
    }

    dest[length] = EOS;
    return length > 0;
}

stock Missions_SetCompleted(playerid,number)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    s_MissionDone[playerid] = number;

    if (s_MissionLoaded[playerid])
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT INTO player_missions (account_id, mission_nr) VALUES (%d, %d) ON DUPLICATE KEY UPDATE mission_nr = VALUES(mission_nr)",Account_GetId(playerid),number));
    }
}

stock Missions_Reset(playerid)
{
    s_MissionOn[playerid] = 0;
    s_MissionStage[playerid] = 0;
    s_MissionDone[playerid] = 0;
    s_MissionLoaded[playerid] = false;
}

stock Missions_Begin(playerid)
{
    new line[MISSIONS_MESSAGE_LEN];
    Phone_Beep(playerid);
    s_MissionOn[playerid] = s_MissionPlayNumber;
    s_MissionStage[playerid] = 1;
    format(line,sizeof(line),"~w~Mission started: ~n~~r~%s",s_MissionTitle[MISSIONS_SLOT_PLAY]);
    GameTextForPlayer(playerid,line,5000,3);

    for (new i = 0;i < 3;i++)
    {
        SendClientMessage(playerid,COLOR_YELLOW2,s_MissionText[MISSIONS_SLOT_PLAY][i]);
    }

    if (s_MissionToggle[MISSIONS_SLOT_PLAY] == 1)
    {
        SetPlayerCheckpoint(playerid,s_MissionPoint[MISSIONS_SLOT_PLAY][0][0],s_MissionPoint[MISSIONS_SLOT_PLAY][0][1],s_MissionPoint[MISSIONS_SLOT_PLAY][0][2],MISSIONS_CHECKPOINT_RADIUS);
    }
}

stock Missions_Advance(playerid,bool:useCheckpoints)
{
    new stage = s_MissionStage[playerid], line[MISSIONS_MESSAGE_LEN];
    Phone_Beep(playerid);
    GameTextForPlayer(playerid,s_MissionGameText[MISSIONS_SLOT_PLAY][stage - 1],MISSIONS_GAME_TEXT_MS,MISSIONS_GAME_TEXT_STYLE);

    if (stage < MISSIONS_POINTS)
    {
        for (new i = 0;i < 3;i++)
        {
            SendClientMessage(playerid,COLOR_YELLOW2,s_MissionText[MISSIONS_SLOT_PLAY][stage * 3 + i]);
        }

        if (useCheckpoints)
        {
            DisablePlayerCheckpoint(playerid);
            SetPlayerCheckpoint(playerid,s_MissionPoint[MISSIONS_SLOT_PLAY][stage][0],s_MissionPoint[MISSIONS_SLOT_PLAY][stage][1],s_MissionPoint[MISSIONS_SLOT_PLAY][stage][2],MISSIONS_CHECKPOINT_RADIUS);
        }

        s_MissionStage[playerid] = stage + 1;
        return;
    }

    format(line,sizeof(line),"..:: Mission Passed : %s | Reward received: $%d ::..",s_MissionTitle[MISSIONS_SLOT_PLAY],s_MissionReward[MISSIONS_SLOT_PLAY]);
    SendClientMessage(playerid,COLOR_GREEN,line);

    if (useCheckpoints)
    {
        DisablePlayerCheckpoint(playerid);
    }

    Account_SetCash(playerid,Account_GetCash(playerid) + s_MissionReward[MISSIONS_SLOT_PLAY]);
    Missions_SetCompleted(playerid,s_MissionOn[playerid]);
    s_MissionStage[playerid] = 0;
    s_MissionOn[playerid] = 0;
}

stock Missions_ReachCheckpoint(playerid)
{
    if (s_MissionStage[playerid] > 0 && s_MissionToggle[MISSIONS_SLOT_PLAY] == 1 && Karting_GetStage(playerid) == KARTING_STAGE_NONE)
    {
        Missions_Advance(playerid,true);
    }
}

stock Missions_Watch(playerid)
{
    if (s_MissionOn[playerid] <= 0 || s_MissionToggle[MISSIONS_SLOT_PLAY] != 0)
    {
        return;
    }

    new stage = s_MissionStage[playerid];

    if (stage < 1 || stage > MISSIONS_POINTS)
    {
        return;
    }

    if (Property_IsNear(playerid,MISSIONS_NEAR_RADIUS,s_MissionPoint[MISSIONS_SLOT_PLAY][stage - 1][0],s_MissionPoint[MISSIONS_SLOT_PLAY][stage - 1][1],s_MissionPoint[MISSIONS_SLOT_PLAY][stage - 1][2]))
    {
        Missions_Advance(playerid,false);
    }
}

stock Missions_Fail(playerid)
{
    if (s_MissionOn[playerid] > 0)
    {
        GameTextForPlayer(playerid,"~r~Mission failed",5000,3);
        s_MissionOn[playerid] = 0;
    }
}

stock Missions_Save(playerid,const name[])
{
    new maker[MISSIONS_MAKER_LEN], line[MISSIONS_MESSAGE_LEN], number = random(999);
    GetPlayerName(playerid,maker,sizeof(maker));

    if (number == 0)
    {
        number = 1;
    }

    if (s_MissionToggle[MISSIONS_SLOT_MAKER] != 0 && s_MissionToggle[MISSIONS_SLOT_MAKER] != 1)
    {
        s_MissionToggle[MISSIONS_SLOT_MAKER] = 1;
    }

    new String:sql = str_new("REPLACE INTO missions (name, maker, title, number, reward, toggle");

    for (new i = 0;i < MISSIONS_TEXTS;i++)
    {
        str_append_format(sql,", text%d",i + 1);
    }

    for (new i = 0;i < MISSIONS_GAME_TEXTS;i++)
    {
        str_append_format(sql,", gtext%d",i + 1);
    }

    for (new i = 0;i < MISSIONS_POINTS;i++)
    {
        str_append_format(sql,", cp%dx, cp%dy, cp%dz",i + 1,i + 1,i + 1);
    }

    str_append_format(sql,") VALUES ('%e', '%e', '%e', %d, %d, %d",name,maker,s_MissionTitle[MISSIONS_SLOT_MAKER],number,s_MissionReward[MISSIONS_SLOT_MAKER],s_MissionToggle[MISSIONS_SLOT_MAKER]);

    for (new i = 0;i < MISSIONS_TEXTS;i++)
    {
        str_append_format(sql,", '%e'",s_MissionText[MISSIONS_SLOT_MAKER][i]);
    }

    for (new i = 0;i < MISSIONS_GAME_TEXTS;i++)
    {
        str_append_format(sql,", '%e'",s_MissionGameText[MISSIONS_SLOT_MAKER][i]);
    }

    for (new i = 0;i < MISSIONS_POINTS;i++)
    {
        str_append_format(sql,", %f, %f, %f",s_MissionPoint[MISSIONS_SLOT_MAKER][i][0],s_MissionPoint[MISSIONS_SLOT_MAKER][i][1],s_MissionPoint[MISSIONS_SLOT_MAKER][i][2]);
    }

    str_append_format(sql,")");
    mysql_tquery_s(g_Mysql,sql);
    format(line,sizeof(line),"%s Mission Saved.",name);
    SendClientMessage(playerid,COLOR_GREEN,line);
}

static Missions_ReadRow(slot)
{
    new column[16];
    cache_get_value_name(0,"title",s_MissionTitle[slot],MISSIONS_LINE_LEN);
    cache_get_value_name_int(0,"reward",s_MissionReward[slot]);
    cache_get_value_name_int(0,"toggle",s_MissionToggle[slot]);

    for (new i = 0;i < MISSIONS_TEXTS;i++)
    {
        format(column,sizeof(column),"text%d",i + 1);
        cache_get_value_name(0,column,s_MissionText[slot][i],MISSIONS_LINE_LEN);
    }

    for (new i = 0;i < MISSIONS_GAME_TEXTS;i++)
    {
        format(column,sizeof(column),"gtext%d",i + 1);
        cache_get_value_name(0,column,s_MissionGameText[slot][i],MISSIONS_LINE_LEN);
    }

    for (new i = 0;i < MISSIONS_POINTS;i++)
    {
        format(column,sizeof(column),"cp%dx",i + 1);
        cache_get_value_name_float(0,column,s_MissionPoint[slot][i][0]);
        format(column,sizeof(column),"cp%dy",i + 1);
        cache_get_value_name_float(0,column,s_MissionPoint[slot][i][1]);
        format(column,sizeof(column),"cp%dz",i + 1);
        cache_get_value_name_float(0,column,s_MissionPoint[slot][i][2]);
    }
}

stock Missions_Load(playerid,const name[])
{
    yield 1;

    new missionName[MISSIONS_NAME_LEN];
    strcopy(missionName,name,MISSIONS_NAME_LEN);

    await mysql_aquery_s(g_Mysql,str_format("SELECT * FROM missions WHERE name = '%e' LIMIT 1",missionName),false);

    new line[MISSIONS_MESSAGE_LEN];

    if (mysql_errno(g_Mysql) != 0 || cache_num_rows() == 0)
    {
        if (IsPlayerConnected(playerid))
        {
            SendClientMessage(playerid,COLOR_GREEN,"Mission File not found.");
        }

        return;
    }

    Missions_ReadRow(MISSIONS_SLOT_PLAY);
    cache_get_value_name(0,"maker",s_MissionPlayMaker,MISSIONS_MAKER_LEN);
    cache_get_value_name_int(0,"number",s_MissionPlayNumber);

    if (IsPlayerConnected(playerid))
    {
        format(line,sizeof(line),"%s Mission Loaded.",missionName);
        SendClientMessage(playerid,COLOR_GREEN,line);
    }

    format(line,sizeof(line),"Mission Available: %s, By : %s | Reward: $%d",s_MissionTitle[MISSIONS_SLOT_PLAY],s_MissionPlayMaker,s_MissionReward[MISSIONS_SLOT_PLAY]);
    SendClientMessageToAll(COLOR_GREEN,line);
    s_MissionPlayable = s_MissionPlayNumber;
}

static Missions_LoadPlayer(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT mission_nr FROM player_missions WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("missions","row load failed for player %d",playerid);
        return;
    }

    new number = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"mission_nr",number);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO player_missions (account_id) VALUES (%d)",accountid));
    }

    s_MissionDone[playerid] = number;
    s_MissionLoaded[playerid] = true;
    Player_LoaderDone(playerid,MISSIONS_LOADER,token);
}

stock Missions_BuildTableSql(sql[],size = sizeof(sql))
{
    new part[96];
    format(sql,size,"CREATE TABLE IF NOT EXISTS missions (name VARCHAR(32) NOT NULL, maker VARCHAR(24) NOT NULL DEFAULT '', title VARCHAR(128) NOT NULL DEFAULT '', number INT NOT NULL DEFAULT 0, reward INT NOT NULL DEFAULT 0, toggle INT NOT NULL DEFAULT 1");

    for (new i = 0;i < MISSIONS_TEXTS;i++)
    {
        format(part,sizeof(part),", text%d VARCHAR(128) NOT NULL DEFAULT ''",i + 1);
        strcat(sql,part,size);
    }

    for (new i = 0;i < MISSIONS_GAME_TEXTS;i++)
    {
        format(part,sizeof(part),", gtext%d VARCHAR(128) NOT NULL DEFAULT ''",i + 1);
        strcat(sql,part,size);
    }

    for (new i = 0;i < MISSIONS_POINTS;i++)
    {
        format(part,sizeof(part),", cp%dx FLOAT NOT NULL DEFAULT 0, cp%dy FLOAT NOT NULL DEFAULT 0, cp%dz FLOAT NOT NULL DEFAULT 0",i + 1,i + 1,i + 1);
        strcat(sql,part,size);
    }

    strcat(sql,", PRIMARY KEY (name)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci",size);
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
public Missions_LoadStart(playerid,accountid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Missions_LoadPlayer(playerid,accountid,token);
    }

    return 1;
}

public Missions_PredicateOnMission(playerid)
{
    return Missions_IsOnMission(playerid) ? 1 : 0;
}
