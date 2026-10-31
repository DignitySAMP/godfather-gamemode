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
#define NEWS_PAPER_COUNT (10)
#define NEWS_PAPER_LINES (7)
#define NEWS_MAKER_LEN (25)
#define NEWS_TITLE_LEN (64)
#define NEWS_LINE_LEN (128)
#define NEWS_DEFAULT_TEXT "None"
#define NEWS_BUILDING_X (-2050.8962)
#define NEWS_BUILDING_Y (460.0262)
#define NEWS_BUILDING_Z (35.1719)
#define NEWS_BUILDING_RADIUS (3.0)
#define NEWS_TEXT_LEN (192)

static bool:s_NewsPaperUsed[NEWS_PAPER_COUNT];
static s_NewsPaperSafe[NEWS_PAPER_COUNT];
static s_NewsPaperMaker[NEWS_PAPER_COUNT][NEWS_MAKER_LEN];
static s_NewsPaperTitle[NEWS_PAPER_COUNT][NEWS_TITLE_LEN];
static s_NewsPaperText[NEWS_PAPER_COUNT][NEWS_PAPER_LINES][NEWS_LINE_LEN];

static bool:s_NewsHasPaper[MAX_PLAYERS];
static s_NewsCopyMaker[MAX_PLAYERS][NEWS_MAKER_LEN];
static s_NewsCopyTitle[MAX_PLAYERS][NEWS_TITLE_LEN];
static s_NewsCopyText[MAX_PLAYERS][NEWS_PAPER_LINES][NEWS_LINE_LEN];

forward News_LoadOnBoot();
forward Task:News_LoadPapers();

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
stock bool:News_IsValidPaper(paper)
{
    return paper >= 0 && paper < NEWS_PAPER_COUNT;
}

stock bool:News_IsPaperUsed(paper)
{
    return News_IsValidPaper(paper) && s_NewsPaperUsed[paper];
}

stock News_GetPaperMaker(paper,dest[],size = sizeof(dest))
{
    if (!News_IsValidPaper(paper))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_NewsPaperMaker[paper],size);
}

stock News_GetPaperTitle(paper,dest[],size = sizeof(dest))
{
    if (!News_IsValidPaper(paper))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_NewsPaperTitle[paper],size);
}

stock News_SavePaper(paper)
{
    if (!News_IsValidPaper(paper))
    {
        return;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE news_papers SET used = %d, maker = '%e', title = '%e', text1 = '%e', text2 = '%e', text3 = '%e', text4 = '%e', text5 = '%e', text6 = '%e', text7 = '%e', safe_saving = %d WHERE paper_id = %d",s_NewsPaperUsed[paper] ? 1 : 0,s_NewsPaperMaker[paper],s_NewsPaperTitle[paper],s_NewsPaperText[paper][0],s_NewsPaperText[paper][1],s_NewsPaperText[paper][2],s_NewsPaperText[paper][3],s_NewsPaperText[paper][4],s_NewsPaperText[paper][5],s_NewsPaperText[paper][6],s_NewsPaperSafe[paper],paper));
}

static News_ResetPaper(paper)
{
    s_NewsPaperUsed[paper] = false;
    s_NewsPaperSafe[paper] = 0;
    strcopy(s_NewsPaperMaker[paper],NEWS_DEFAULT_TEXT,NEWS_MAKER_LEN);
    strcopy(s_NewsPaperTitle[paper],NEWS_DEFAULT_TEXT,NEWS_TITLE_LEN);

    for (new line = 0;line < NEWS_PAPER_LINES;line++)
    {
        strcopy(s_NewsPaperText[paper][line],NEWS_DEFAULT_TEXT,NEWS_LINE_LEN);
    }
}

stock News_ClearPaper(paper)
{
    if (!News_IsValidPaper(paper))
    {
        return;
    }

    News_ResetPaper(paper);
    News_SavePaper(paper);
}

stock News_StorePaperHeader(paper,const maker[],const title[])
{
    if (!News_IsValidPaper(paper))
    {
        return;
    }

    strcopy(s_NewsPaperMaker[paper],maker,NEWS_MAKER_LEN);
    strcopy(s_NewsPaperTitle[paper],title,NEWS_TITLE_LEN);
}

stock News_StorePaperLine(paper,line,const text[])
{
    if (!News_IsValidPaper(paper) || line < 0 || line >= NEWS_PAPER_LINES)
    {
        return;
    }

    strcopy(s_NewsPaperText[paper][line],text,NEWS_LINE_LEN);
}

stock News_FinishPaper(paper)
{
    if (!News_IsValidPaper(paper))
    {
        return;
    }

    s_NewsPaperUsed[paper] = true;
    News_SavePaper(paper);
}

stock bool:News_HasPaper(playerid)
{
    return Util_IsValidPlayer(playerid) && s_NewsHasPaper[playerid];
}

stock News_LoadPaperCopy(playerid,paper)
{
    if (!Util_IsValidPlayer(playerid) || !News_IsValidPaper(paper))
    {
        return;
    }

    strcopy(s_NewsCopyMaker[playerid],s_NewsPaperMaker[paper],NEWS_MAKER_LEN);
    strcopy(s_NewsCopyTitle[playerid],s_NewsPaperTitle[paper],NEWS_TITLE_LEN);

    for (new line = 0;line < NEWS_PAPER_LINES;line++)
    {
        strcopy(s_NewsCopyText[playerid][line],s_NewsPaperText[paper][line],NEWS_LINE_LEN);
    }
}

stock News_GivePaper(playerid,fromid)
{
    if (!Util_IsValidPlayer(playerid) || !Util_IsValidPlayer(fromid))
    {
        return;
    }

    strcopy(s_NewsCopyMaker[playerid],s_NewsCopyMaker[fromid],NEWS_MAKER_LEN);
    strcopy(s_NewsCopyTitle[playerid],s_NewsCopyTitle[fromid],NEWS_TITLE_LEN);

    for (new line = 0;line < NEWS_PAPER_LINES;line++)
    {
        strcopy(s_NewsCopyText[playerid][line],s_NewsCopyText[fromid][line],NEWS_LINE_LEN);
    }

    s_NewsHasPaper[playerid] = true;
}

stock News_PrintPaper(playerid,const title[],const maker[],const lines[NEWS_PAPER_LINES][NEWS_LINE_LEN])
{
    new line[NEWS_TEXT_LEN];
    SendClientMessage(playerid,COLOR_WHITE,"|_______________ Role Play - The Godfather: Newspaper _______________|");
    format(line,sizeof(line),"| %s  |  By News Reporter: %s.",title,maker);
    SendClientMessage(playerid,COLOR_GREEN,line);

    for (new i = 0;i < NEWS_PAPER_LINES;i++)
    {
        SendClientMessage(playerid,COLOR_GREY,lines[i]);
    }

    SendClientMessage(playerid,COLOR_WHITE,"|____________________________________________________________________|");
}

stock News_ShowCopy(playerid,viewerid)
{
    News_PrintPaper(viewerid,s_NewsCopyTitle[playerid],s_NewsCopyMaker[playerid],s_NewsCopyText[playerid]);
}

stock News_ShowPaper(playerid,paper)
{
    if (News_IsValidPaper(paper))
    {
        News_PrintPaper(playerid,s_NewsPaperTitle[paper],s_NewsPaperMaker[paper],s_NewsPaperText[paper]);
    }
}

stock News_Send(colour,const text[])
{
    foreach (new playerid : Player)
    {
        if (!IsPlayerNPC(playerid) && Chat_IsNewsEnabled(playerid))
        {
            SendClientMessage(playerid,colour,text);
        }
    }
}

static News_ReadPaperRow(row,paper)
{
    new used = 0;
    cache_get_value_name_int(row,"used",used);
    s_NewsPaperUsed[paper] = used != 0;
    cache_get_value_name_int(row,"safe_saving",s_NewsPaperSafe[paper]);
    cache_get_value_name(row,"maker",s_NewsPaperMaker[paper],NEWS_MAKER_LEN);
    cache_get_value_name(row,"title",s_NewsPaperTitle[paper],NEWS_TITLE_LEN);
    cache_get_value_name(row,"text1",s_NewsPaperText[paper][0],NEWS_LINE_LEN);
    cache_get_value_name(row,"text2",s_NewsPaperText[paper][1],NEWS_LINE_LEN);
    cache_get_value_name(row,"text3",s_NewsPaperText[paper][2],NEWS_LINE_LEN);
    cache_get_value_name(row,"text4",s_NewsPaperText[paper][3],NEWS_LINE_LEN);
    cache_get_value_name(row,"text5",s_NewsPaperText[paper][4],NEWS_LINE_LEN);
    cache_get_value_name(row,"text6",s_NewsPaperText[paper][5],NEWS_LINE_LEN);
    cache_get_value_name(row,"text7",s_NewsPaperText[paper][6],NEWS_LINE_LEN);
}

static News_ClearCopy(playerid)
{
    s_NewsHasPaper[playerid] = false;
    s_NewsCopyMaker[playerid][0] = EOS;
    s_NewsCopyTitle[playerid][0] = EOS;

    for (new line = 0;line < NEWS_PAPER_LINES;line++)
    {
        s_NewsCopyText[playerid][line][0] = EOS;
    }
}

async Task:News_LoadPapers()
{
    await task_ticks(1);

    for (new paper = 0;paper < NEWS_PAPER_COUNT;paper++)
    {
        News_ResetPaper(paper);
    }

    await mysql_aquery_s(g_Mysql,str_new("SELECT * FROM news_papers ORDER BY paper_id"),false);

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("news","the news_papers table could not be read");
        return async 0;
    }

    new bool:found[NEWS_PAPER_COUNT], loaded = 0;

    for (new row = 0,rows = cache_num_rows();row < rows;row++)
    {
        new paper = -1;
        cache_get_value_name_int(row,"paper_id",paper);

        if (!News_IsValidPaper(paper))
        {
            Log_Error("news","paper %d is outside the table, raise NEWS_PAPER_COUNT",paper);
            continue;
        }

        News_ReadPaperRow(row,paper);
        found[paper] = true;
        loaded++;
    }

    for (new paper = 0;paper < NEWS_PAPER_COUNT;paper++)
    {
        if (!found[paper])
        {
            mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO news_papers (paper_id) VALUES (%d)",paper));
        }
    }

    return async loaded;
}

static News_BootTask()
{
    yield 1;

    await News_LoadPapers();
    Log_Info("news","%d newspapers loaded",NEWS_PAPER_COUNT);
    Boot_LoaderDone();
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
public News_LoadOnBoot()
{
    News_BootTask();
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
    News_ClearCopy(playerid);
}

hook Account_OnLogout(playerid,accountid)
{
    News_ClearCopy(playerid);
}
