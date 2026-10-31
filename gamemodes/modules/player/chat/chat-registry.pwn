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
#define CHAT_INTERCEPTORS_MAX (24)
#define CHAT_HANDLER_LEN (32)

enum
{
    CHAT_SLOT_MUTED = 100,
    CHAT_SLOT_CLOTHES = 200,
    CHAT_SLOT_REGISTRATION = 300,
    CHAT_SLOT_MARRIAGE = 400,
    CHAT_SLOT_PAPER = 500,
    CHAT_SLOT_HITMAN_PC = 600,
    CHAT_SLOT_LAWYER = 700,
    CHAT_SLOT_LIVE = 800,
    CHAT_SLOT_PHONE = 900
}

static s_ChatHandlers[CHAT_INTERCEPTORS_MAX][CHAT_HANDLER_LEN];
static s_ChatPriorities[CHAT_INTERCEPTORS_MAX];
static s_ChatHandlerCount;
static bool:s_ChatRealChat = true;

forward Chat_SayDefault(playerid,const text[]);

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
stock bool:Chat_RegisterInterceptor(const handler[],priority)
{
    if (!pawn_public_exists(handler))
    {
        Log_Error("chat","interceptor %s is not a public, it is not registered",handler);
        return false;
    }

    for (new i = 0;i < s_ChatHandlerCount;i++)
    {
        if (!strcmp(s_ChatHandlers[i],handler,true))
        {
            return false;
        }
    }

    if (s_ChatHandlerCount >= CHAT_INTERCEPTORS_MAX)
    {
        Log_Error("chat","no room for interceptor %s: raise CHAT_INTERCEPTORS_MAX",handler);
        return false;
    }

    new at = s_ChatHandlerCount;

    while (at > 0 && s_ChatPriorities[at - 1] > priority)
    {
        strcopy(s_ChatHandlers[at],s_ChatHandlers[at - 1],CHAT_HANDLER_LEN);
        s_ChatPriorities[at] = s_ChatPriorities[at - 1];
        at--;
    }

    strcopy(s_ChatHandlers[at],handler,CHAT_HANDLER_LEN);
    s_ChatPriorities[at] = priority;
    s_ChatHandlerCount++;
    return true;
}

stock bool:Chat_IsRealChat()
{
    return s_ChatRealChat;
}

Chat_RouteText(playerid,const text[])
{
    if (IsPlayerNPC(playerid))
    {
        return 0;
    }

    for (new i = 0;i < s_ChatHandlerCount;i++)
    {
        if (CallLocalFunction(s_ChatHandlers[i],"ds",playerid,text) != 0)
        {
            return 0;
        }
    }

    return Chat_SayDefault(playerid,text);
}
