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
#define TUTORIAL_END_SECOND (127)
#define TUTORIAL_WORLD_BASE (5000)

enum E_TUTORIAL_SHOT
{
    E_TUTORIAL_SHOT_SECOND,
    E_TUTORIAL_SHOT_LENGTH,
    Float:E_TUTORIAL_SHOT_FROM_X,
    Float:E_TUTORIAL_SHOT_FROM_Y,
    Float:E_TUTORIAL_SHOT_FROM_Z,
    Float:E_TUTORIAL_SHOT_TO_X,
    Float:E_TUTORIAL_SHOT_TO_Y,
    Float:E_TUTORIAL_SHOT_TO_Z,
    Float:E_TUTORIAL_SHOT_LOOK_X,
    Float:E_TUTORIAL_SHOT_LOOK_Y,
    Float:E_TUTORIAL_SHOT_LOOK_Z
}

static const s_TutorialShots[][E_TUTORIAL_SHOT] =
{
    {3, 11000, 1390.0, -820.0, 95.0, 1430.0, -860.0, 110.0, 1544.0, -1353.0, 250.0},
    {14, 16000, 1440.0, -1700.0, 45.0, 1520.0, -1700.0, 45.0, 1481.0, -1772.0, 20.0},
    {30, 12000, 1500.0, -1625.0, 52.0, 1535.0, -1635.0, 46.0, 1555.0, -1675.0, 22.0},
    {52, 16000, 1470.0, -1660.0, 48.0, 1480.0, -1690.0, 48.0, 1550.0, -1672.0, 20.0},
    {74, 22000, 2450.0, -1650.0, 30.0, 2530.0, -1650.0, 30.0, 2495.0, -1687.0, 13.0},
    {96, 12000, 1990.0, -1720.0, 30.0, 1900.0, -1720.0, 30.0, 1940.0, -1772.0, 13.0},
    {108, 11000, 310.0, -1990.0, 40.0, 430.0, -1990.0, 40.0, 380.0, -2060.0, 7.0},
    {119, 8000, 1250.0, -1250.0, 140.0, 1300.0, -1400.0, 140.0, 1544.0, -1353.0, 150.0}
};

static s_TutorialSecond[MAX_PLAYERS];

forward Tutorial_OnFinished(playerid);

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
stock bool:Tutorial_IsActive(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_TutorialSecond[playerid] >= 1;
}

stock Tutorial_SetSecond(playerid,second)
{
    if (playerid >= 0 && playerid < MAX_PLAYERS)
    {
        s_TutorialSecond[playerid] = second;
    }
}

stock Tutorial_Begin(playerid)
{
    Tutorial_SetSecond(playerid,1);
}

static Tutorial_Camera(playerid,second)
{
    for (new i = 0; i < sizeof(s_TutorialShots); i++)
    {
        if (s_TutorialShots[i][E_TUTORIAL_SHOT_SECOND] != second)
        {
            continue;
        }

        SetPlayerInterior(playerid,0);
        SetPlayerVirtualWorld(playerid,TUTORIAL_WORLD_BASE + playerid);
        SetPlayerPos(playerid,s_TutorialShots[i][E_TUTORIAL_SHOT_TO_X],s_TutorialShots[i][E_TUTORIAL_SHOT_TO_Y],s_TutorialShots[i][E_TUTORIAL_SHOT_TO_Z] - 30.0);
        InterpolateCameraPos(playerid,s_TutorialShots[i][E_TUTORIAL_SHOT_FROM_X],s_TutorialShots[i][E_TUTORIAL_SHOT_FROM_Y],s_TutorialShots[i][E_TUTORIAL_SHOT_FROM_Z],s_TutorialShots[i][E_TUTORIAL_SHOT_TO_X],s_TutorialShots[i][E_TUTORIAL_SHOT_TO_Y],s_TutorialShots[i][E_TUTORIAL_SHOT_TO_Z],s_TutorialShots[i][E_TUTORIAL_SHOT_LENGTH],CAMERA_MOVE);
        InterpolateCameraLookAt(playerid,s_TutorialShots[i][E_TUTORIAL_SHOT_LOOK_X],s_TutorialShots[i][E_TUTORIAL_SHOT_LOOK_Y],s_TutorialShots[i][E_TUTORIAL_SHOT_LOOK_Z],s_TutorialShots[i][E_TUTORIAL_SHOT_LOOK_X],s_TutorialShots[i][E_TUTORIAL_SHOT_LOOK_Y],s_TutorialShots[i][E_TUTORIAL_SHOT_LOOK_Z],s_TutorialShots[i][E_TUTORIAL_SHOT_LENGTH],CAMERA_MOVE);
        return;
    }
}

static Tutorial_Header(playerid,const title[])
{
    new line[64];
    format(line,sizeof(line),"|____ Tutorial: %s ____|",title);
    SendClientMessage(playerid,COLOR_YELLOW,line);
}

static Tutorial_Text(playerid,const text[])
{
    SendClientMessage(playerid,COLOR_YELLOW2,text);
}

static Tutorial_Finish(playerid)
{
    s_TutorialSecond[playerid] = 0;
    Account_SetTutorial(playerid,1);
    Chat_SetOocEnabled(playerid,true);
    Chat_SetNewsEnabled(playerid,true);
    Chat_SetFamilyEnabled(playerid,true);
    TogglePlayerControllable(playerid,true);
    SetPlayerVirtualWorld(playerid,0);
    SetCameraBehindPlayer(playerid);
    pawn_call_public("Tutorial_OnFinished","d",playerid);
    Spawn_Place(playerid);
}

stock Tutorial_Step(playerid)
{
    if (!Tutorial_IsActive(playerid))
    {
        return;
    }

    if (!Account_IsLoggedIn(playerid))
    {
        s_TutorialSecond[playerid] = 0;
        return;
    }

    s_TutorialSecond[playerid]++;
    Tutorial_Camera(playerid,s_TutorialSecond[playerid]);

    switch (s_TutorialSecond[playerid])
    {
        case 3:
        {
            Tutorial_Text(playerid,"|____ Tutorial: The beginning ____|");
            Tutorial_Text(playerid,"Hi there, I can see that you are new, so here's a quick Tutorial.");
            Tutorial_Text(playerid,"Every new player needs to know what he / she, can and can't do.");
            Tutorial_Text(playerid,"I will give you quite some information, so please pay attention to avoid questions later on.");
        }
        case 14:
        {
            Tutorial_Header(playerid,"Kind of server");
        }
        case 16:
        {
            Tutorial_Text(playerid,"This server is a RP server which stands for Role Playing.");
            Tutorial_Text(playerid,"We are absolutely not interested in players that just come along and Deathmatch.");
            Tutorial_Text(playerid,"The name you have also matters a lot, other players are getting used to your chosen name");
            Tutorial_Text(playerid,"so it's better to have a name like for example: Oliver_Wood.");
            Tutorial_Text(playerid,"If you want to know more about how to RP, visit our forums and search for the topic.");
            Tutorial_Text(playerid,"(You can find the forum on our webpage: http://www.godfather-rp.com");
        }
        case 30:
        {
            Tutorial_Header(playerid,"Requesting Help");
        }
        case 32:
        {
            Tutorial_Text(playerid,"If you are confused and would like to know some more information when you are ingame");
            Tutorial_Text(playerid,"simply just ask any Player or an Admin (/admins) in a common way.");
            Tutorial_Text(playerid,"Just use common lines like: Hi, could you help me a sec please?");
            Tutorial_Text(playerid,"Don't start to shout or curse at someone, because it will only make you look worse..");
            Tutorial_Text(playerid,"And you might end up banned, which you want to skip of course.");
            Tutorial_Text(playerid,"Use the commands /o (OOC) /w (Whisper) /sms (If you have the Phone Number) to talk to someone.");
        }
        case 52:
        {
            Tutorial_Header(playerid,"Cheating & Abusing");
        }
        case 54:
        {
            Tutorial_Text(playerid,"We wish that n0beit was never made and we certainly don't allow players to use it.");
            Tutorial_Text(playerid,"That's why we don't want YOU to cheat, or allow other players to cheat.");
            Tutorial_Text(playerid,"If you see someone cheating, please report it with /report right away.");
            Tutorial_Text(playerid,"Bug abusing, or in any other way stuff abusing is just as bad as Cheating.");
            Tutorial_Text(playerid,"So we don't want YOU to abuse as well, simply use the /report as well if you see");
            Tutorial_Text(playerid,"someone abusing something.");
        }
        case 74:
        {
            Tutorial_Header(playerid,"Respect");
        }
        case 76:
        {
            Tutorial_Text(playerid,"First of all I like to start with Admins, respect Admins in any way.");
            Tutorial_Text(playerid,"We are all trying to keep everyone satisfied and trying to help everyone in any way possible.");
            Tutorial_Text(playerid,"Secondly, don't curse / shout / swear at other players, this will end you up muted / banned.");
            Tutorial_Text(playerid,"Just treat people with respect, just like you want to be respected.");
        }
        case 96:
        {
            Tutorial_Header(playerid,"Drive-by");
        }
        case 98:
        {
            Tutorial_Text(playerid,"We don't allow Drive-by's on this server, since it's lame and simple to kill.");
            Tutorial_Text(playerid,"And it's deathmatching, which we definitely don't allow.");
            Tutorial_Text(playerid,"Don't do this if you don't want yourself to get banned.");
        }
        case 108:
        {
            Tutorial_Header(playerid,"Language & Advertising");
        }
        case 110:
        {
            Tutorial_Text(playerid,"We'd like you to use English in any chat.");
            Tutorial_Text(playerid,"If you want to talk with someone in your own Language, use the /w or /sms commands");
            Tutorial_Text(playerid,"Advertising is not allowed as well, advertising will get you banned as well.");
        }
        case 119:
        {
            Tutorial_Header(playerid,"The End");
        }
        case 121:
        {
            Tutorial_Text(playerid,"So that was it, probably obvious but we still want you to remember our rules.");
            Tutorial_Text(playerid,"Just keep reminding them and have fun!");
            Tutorial_Text(playerid,"Greetings from: Role Play - The Godfather Admin Team.");
        }
        case TUTORIAL_END_SECOND:
        {
            Tutorial_Finish(playerid);
        }
    }
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
public Tutorial_OnFinished(playerid)
{
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
    s_TutorialSecond[playerid] = 0;
}

hook OnPlayerDisconnect(playerid,reason)
{
    s_TutorialSecond[playerid] = 0;
}

hook Account_OnLogout(playerid,accountid)
{
    s_TutorialSecond[playerid] = 0;
}

hook Account_OnRegistrationDone(playerid)
{
    Tutorial_Begin(playerid);
}

hook Tick_OnPlayerSecond(playerid)
{
    Tutorial_Step(playerid);
}
