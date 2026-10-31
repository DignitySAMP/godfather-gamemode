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
#define MUSIC_LOADER "Music"
#define MUSIC_SONG_COUNT (7)

static const s_MusicSongs[MUSIC_SONG_COUNT] =
{
    1187,
    1185,
    1183,
    1097,
    1076,
    1068,
    1062
};

static s_MusicTrack[MAX_PLAYERS];
static s_MusicCdPlayer[MAX_PLAYERS];
static bool:s_MusicLoaded[MAX_PLAYERS];

forward Music_BeginLoad(playerid,token);

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
stock bool:Music_IsLoaded(playerid)
{
    return Util_IsValidPlayer(playerid) && s_MusicLoaded[playerid];
}

stock bool:Music_HasCdPlayer(playerid)
{
    return Music_IsLoaded(playerid) && s_MusicCdPlayer[playerid] != 0;
}

stock bool:Music_SetCdPlayer(playerid,value)
{
    if (!Music_IsLoaded(playerid))
    {
        return false;
    }

    s_MusicCdPlayer[playerid] = value;
    mysql_tquery_s(g_Mysql,str_format("UPDATE player_music SET cd_player = %d WHERE account_id = %d",value,Account_GetId(playerid)));
    return true;
}

stock Music_GetSound(track)
{
    if (track < 0 || track >= MUSIC_SONG_COUNT)
    {
        return s_MusicSongs[0];
    }

    return s_MusicSongs[track];
}

stock Music_PlayCurrent(playerid)
{
    PlayerPlaySound(playerid,Music_GetSound(s_MusicTrack[playerid]),0.0,0.0,0.0);
}

stock Music_NextTrack(playerid)
{
    s_MusicTrack[playerid] = (s_MusicTrack[playerid] + 1) % MUSIC_SONG_COUNT;
    Music_PlayCurrent(playerid);
}

static Music_Reset(playerid)
{
    s_MusicTrack[playerid] = 0;
    s_MusicCdPlayer[playerid] = 0;
    s_MusicLoaded[playerid] = false;
}

static Music_LoadPlayer(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT cd_player FROM player_music WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("music","cd player load failed for player %d",playerid);
        return;
    }

    new cdPlayer = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"cd_player",cdPlayer);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT INTO player_music (account_id, cd_player) VALUES (%d, 0) ON DUPLICATE KEY UPDATE cd_player = cd_player",accountid));
    }

    s_MusicCdPlayer[playerid] = cdPlayer;
    s_MusicLoaded[playerid] = true;
    Player_LoaderDone(playerid,MUSIC_LOADER,token);
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
public Music_BeginLoad(playerid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Music_LoadPlayer(playerid,Player_GetLoadAccount(playerid),token);
    }

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
    Music_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Music_Reset(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    Music_Reset(playerid);
    SetTimerEx("Music_BeginLoad",0,false,"dd",playerid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Music_Reset(playerid);
}

hook Shops_OnCdPlayerBought(playerid)
{
    Music_SetCdPlayer(playerid,1);
}

hook Frisk_OnBuild(playerid,targetid)
{
    if (Music_HasCdPlayer(targetid))
    {
        Misc_SetFriskItem(MISC_FRISK_ITEM_CDPLAYER,true);
    }
}
