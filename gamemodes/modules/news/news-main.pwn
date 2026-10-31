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

hook OnGameModeInit()
{
    Boot_RegisterLoader("News_LoadOnBoot");
    Chat_RegisterInterceptor("News_ChatPaper",CHAT_SLOT_PAPER);
    Chat_RegisterInterceptor("News_ChatLive",CHAT_SLOT_LIVE);
    Offer_RegisterAccept("live","News_LiveAccept");
    Offer_RegisterCancel("live","News_LiveCancel");
}

hook OnMigrationRun()
{
    Migration_Add("news-1-papers", "CREATE TABLE IF NOT EXISTS news_papers (paper_id INT UNSIGNED NOT NULL, used INT NOT NULL DEFAULT 0, maker VARCHAR(24) NOT NULL DEFAULT 'None', title VARCHAR(64) NOT NULL DEFAULT 'None', text1 VARCHAR(128) NOT NULL DEFAULT 'None', text2 VARCHAR(128) NOT NULL DEFAULT 'None', text3 VARCHAR(128) NOT NULL DEFAULT 'None', text4 VARCHAR(128) NOT NULL DEFAULT 'None', text5 VARCHAR(128) NOT NULL DEFAULT 'None', text6 VARCHAR(128) NOT NULL DEFAULT 'None', text7 VARCHAR(128) NOT NULL DEFAULT 'None', safe_saving INT NOT NULL DEFAULT 0, PRIMARY KEY (paper_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}
