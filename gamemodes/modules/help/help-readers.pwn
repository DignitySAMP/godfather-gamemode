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
#define HELP_READER_LEN (32)
#define HELP_SEPARATOR "_______________________________________"

enum E_HELP_FIELD
{
    HELP_FIELD_JOB,
    HELP_FIELD_MEMBER,
    HELP_FIELD_LEADER,
    HELP_FIELD_PHONE,
    HELP_FIELD_COUNT
}

static s_HelpReaders[_:HELP_FIELD_COUNT][HELP_READER_LEN];

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
stock bool:Help_RegisterReader(E_HELP_FIELD:field,const handler[])
{
    if (field < HELP_FIELD_JOB || field >= HELP_FIELD_COUNT)
    {
        return false;
    }

    if (!pawn_public_exists(handler))
    {
        Log_Error("help","reader %s is not a public, it is not registered",handler);
        return false;
    }

    strcopy(s_HelpReaders[_:field],handler,HELP_READER_LEN);
    return true;
}

stock Help_ReadField(E_HELP_FIELD:field,playerid)
{
    if (field < HELP_FIELD_JOB || field >= HELP_FIELD_COUNT || s_HelpReaders[_:field][0] == EOS)
    {
        return 0;
    }

    return CallLocalFunction(s_HelpReaders[_:field],"d",playerid);
}
