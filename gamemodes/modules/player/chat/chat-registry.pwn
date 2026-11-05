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

enum e_CHAT_HANDLER
{
    E_CHAT_HANDLER_NAME[CHAT_HANDLER_LEN],
    E_CHAT_HANDLER_PRIORITY
}

static List:s_ChatHandlers;
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
static Chat_CountHandlers()
{
    return list_valid(s_ChatHandlers) ? list_size(s_ChatHandlers) : 0;
}

static Chat_FindHandler(const handler[])
{
    new entry[e_CHAT_HANDLER];

    for (new i = 0, count = Chat_CountHandlers();i < count;i++)
    {
        list_get_arr(s_ChatHandlers,i,entry);

        if (!strcmp(entry[E_CHAT_HANDLER_NAME],handler,true))
        {
            return i;
        }
    }

    return -1;
}

stock bool:Chat_RegisterInterceptor(const handler[],priority)
{
    if (!pawn_public_exists(handler))
    {
        Log_Error("chat","interceptor %s is not a public, it is not registered",handler);
        return false;
    }

    if (Chat_FindHandler(handler) != -1)
    {
        return false;
    }

    if (!list_valid(s_ChatHandlers))
    {
        s_ChatHandlers = list_new();
    }

    new at = Chat_CountHandlers(), entry[e_CHAT_HANDLER];

    while (at > 0 && list_get(s_ChatHandlers,at - 1,_:E_CHAT_HANDLER_PRIORITY) > priority)
    {
        at--;
    }

    strcopy(entry[E_CHAT_HANDLER_NAME],handler,CHAT_HANDLER_LEN);
    entry[E_CHAT_HANDLER_PRIORITY] = priority;
    list_add_arr(s_ChatHandlers,entry,at);
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

    new entry[e_CHAT_HANDLER];

    for (new i = 0;i < Chat_CountHandlers();i++)
    {
        list_get_arr(s_ChatHandlers,i,entry);

        if (CallLocalFunction(entry[E_CHAT_HANDLER_NAME],"ds",playerid,text) != 0)
        {
            return 0;
        }
    }

    return Chat_SayDefault(playerid,text);
}
