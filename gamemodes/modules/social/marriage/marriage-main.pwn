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
    Player_RegisterLoader(MARRIAGE_LOADER);
    Chat_RegisterInterceptor("Marriage_ChatCeremony",CHAT_SLOT_MARRIAGE);
    Offer_RegisterAccept("witness","Marriage_AcceptWitness");
    Offer_RegisterCancel("witness","Marriage_CancelWitness");
    Offer_RegisterAccept("marriage","Marriage_AcceptMarriage");
    Offer_RegisterCancel("marriage","Marriage_CancelMarriage");
    Offer_RegisterAccept("divorce","Marriage_AcceptDivorce");
    Offer_RegisterCancel("divorce","Marriage_CancelDivorce");
    Houses_SetPredicate(HOUSE_PREDICATE_IS_MARRIED,"Marriage_PredicateIsMarried");
    Business_SetProvider(BUSINESS_PROVIDER_IS_MARRIED,"Marriage_PredicateIsMarried");
}

hook OnMigrationRun()
{
    Migration_Add("marriage-1-player-marriage", "CREATE TABLE IF NOT EXISTS player_marriage (account_id INT UNSIGNED NOT NULL, married TINYINT NOT NULL DEFAULT 0, married_to VARCHAR(24) NOT NULL DEFAULT 'No-one', PRIMARY KEY (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}

hook OnPlayerConnect(playerid)
{
    Marriage_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Marriage_SweepLeaver(playerid);
    Marriage_Reset(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    SetTimerEx("Marriage_LoadStart",0,false,"ddd",playerid,accountid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Marriage_Reset(playerid);
}

hook Stats_OnBuild(playerid,targetid)
{
    if (Marriage_IsLoaded(targetid))
    {
        new spouse[MARRIAGE_NAME_LEN];
        Marriage_GetSpouse(targetid,spouse);
        Stats_SetText("MarriedTo",spouse);
    }
}
