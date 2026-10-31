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
#define NEWS_WRITE_NONE (0)
#define NEWS_WRITE_TITLE (1)
#define NEWS_WRITE_LAST (8)

static bool:s_NewsWriting[MAX_PLAYERS];
static s_NewsWritingPaper[MAX_PLAYERS];
static s_NewsWritingLine[MAX_PLAYERS];

forward News_ChatPaper(playerid,const text[]);

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

stock News_BeginWriting(playerid,paper)
{
    if (!Util_IsValidPlayer(playerid) || !News_IsValidPaper(paper))
    {
        return;
    }

    s_NewsWriting[playerid] = true;
    s_NewsWritingPaper[playerid] = paper;
    s_NewsWritingLine[playerid] = NEWS_WRITE_TITLE;
}

static News_StopWriting(playerid)
{
    s_NewsWriting[playerid] = false;
    s_NewsWritingPaper[playerid] = 999;
    s_NewsWritingLine[playerid] = NEWS_WRITE_NONE;
}

static bool:News_IsBlank(const text[])
{
    for (new i = 0;text[i] != EOS;i++)
    {
        if (text[i] > ' ')
        {
            return false;
        }
    }

    return true;
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
public News_ChatPaper(playerid,const text[])
{
    if (!s_NewsWriting[playerid])
    {
        return 0;
    }

    if (News_IsBlank(text))
    {
        if (s_NewsWritingLine[playerid] == NEWS_WRITE_TITLE)
        {
            SendClientMessage(playerid,COLOR_GRAD2,"* Please type in the Title of your Newspaper.");
        }
        else
        {
            SendClientMessage(playerid,COLOR_LIGHTRED,"* Please type in a Text Line of your Newspaper.");
        }

        return 1;
    }

    new paper = s_NewsWritingPaper[playerid], written = 0;

    if (s_NewsWritingLine[playerid] == NEWS_WRITE_TITLE)
    {
        News_StorePaperHeader(paper,Util_GetPlayerName(playerid),text);
        s_NewsWritingLine[playerid] = 2;
        SendClientMessage(playerid,COLOR_LIGHTRED,"* Now you can write down the News Lines, 7 remaining.");
    }
    else
    {
        written = s_NewsWritingLine[playerid] - 1;
        News_StorePaperLine(paper,written - 1,text);

        if (s_NewsWritingLine[playerid] == NEWS_WRITE_LAST)
        {
            News_FinishPaper(paper);
            News_StopWriting(playerid);
        }
        else
        {
            s_NewsWritingLine[playerid]++;
        }
    }

    if (written > 0)
    {
        new line[64];
        format(line,sizeof(line),"* You wrote Line %d of the Newspaper.",written);
        SendClientMessage(playerid,COLOR_LIGHTBLUE,line);

        if (written == NEWS_PAPER_LINES)
        {
            SendClientMessage(playerid,COLOR_LIGHTBLUE,"* Your Newspaper has been added to the News List (for Paper Boys).");
        }
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
    News_StopWriting(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    News_StopWriting(playerid);
}

hook Account_OnLogout(playerid,accountid)
{
    News_StopWriting(playerid);
}
