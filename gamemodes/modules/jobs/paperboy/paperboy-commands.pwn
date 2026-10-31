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
CMD:bring(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Jobs_Is(playerid,JOB_PAPERBOY))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Paper Boy !");
        return 1;
    }

    if (!Paperboy_IsAtBuilding(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not at the News Reporter Building !");
        return 1;
    }

    new number;

    if (sscanf(params,"i",number))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /bring [papernr]");
        return 1;
    }

    if (number < 1 || number > NEWS_PAPER_COUNT)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Paper Number can't be below 1 or above 10 !");
        return 1;
    }

    new paper = number - 1;

    if (!News_IsPaperUsed(paper))
    {
        SendClientMessage(playerid,COLOR_GREY,"   There is no written Newspaper on that number !");
        return 1;
    }

    new title[NEWS_TITLE_LEN], maker[NEWS_MAKER_LEN], line[JOBS_LINE_LEN];
    News_GetPaperTitle(paper,title);
    News_GetPaperMaker(paper,maker);
    format(line,sizeof(line),"* You can now deliver Newspapers to people, Newspaper: %s, By: %s.",title,maker);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    News_LoadPaperCopy(playerid,paper);
    Paperboy_SetBringing(playerid,true);
    return 1;
}
