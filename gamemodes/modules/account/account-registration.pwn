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
#define ACCOUNT_STEP_NONE (0)
#define ACCOUNT_STEP_SEX (1)
#define ACCOUNT_STEP_BIRTHDATE (2)
#define ACCOUNT_STEP_ORIGIN (3)
#define ACCOUNT_MAX_AGE (100)

static s_AccountRegistrationStep[MAX_PLAYERS];
static bool:s_AccountRegistrationBlocked[MAX_PLAYERS];

forward Account_OnRegistrationStart(playerid);
forward Account_OnRegistrationDone(playerid);
forward Account_ChatMuted(playerid,const text[]);
forward Account_ChatRegistration(playerid,const text[]);
forward Account_AskStep(playerid);

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
stock Account_GetRegistrationStep(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return ACCOUNT_STEP_NONE;
    }

    return s_AccountRegistrationStep[playerid];
}

static Account_BlockMenuChord(playerid)
{
    if (!s_AccountRegistrationBlocked[playerid])
    {
        s_AccountRegistrationBlocked[playerid] = true;
        Menu_PushBlock(playerid);
    }
}

static Account_ReleaseMenuChord(playerid)
{
    if (s_AccountRegistrationBlocked[playerid])
    {
        s_AccountRegistrationBlocked[playerid] = false;
        Menu_PopBlock(playerid);
    }
}

stock Account_BeginRegistration(playerid)
{
    s_AccountRegistrationStep[playerid] = ACCOUNT_STEP_SEX;
    Account_BlockMenuChord(playerid);
    pawn_call_public("Account_OnRegistrationStart","d",playerid);
    TogglePlayerControllable(playerid,false);
    SendClientMessage(playerid,COLOR_YELLOW,"Welcome to Role Play - The Godfather server, please fill in some information to proceed.");
    SendClientMessage(playerid,COLOR_LIGHTRED,"Are you a Male or Female? (Type in what you are).");
    Account_AskStep(playerid);
}

static bool:Account_FirstWordIs(const text[],const word[])
{
    new first[32];

    if (sscanf(text,"s[32]",first))
    {
        return false;
    }

    return strlen(first) == strlen(word) && !strcmp(first,word,true);
}

static Account_ParseDate(const text[],&day,&month,&year)
{
    new parts[3], part = 0, value[20], length = 0;

    for (new i = 0;;i++)
    {
        if (text[i] == '/' || text[i] == EOS)
        {
            value[length] = EOS;

            if (part < 3)
            {
                parts[part++] = strval(value);
            }

            length = 0;

            if (text[i] == EOS)
            {
                break;
            }

            continue;
        }

        if (length < sizeof(value) - 1)
        {
            value[length++] = text[i];
        }
    }

    day = parts[0];
    month = parts[1];
    year = parts[2];
}

stock Account_AnswerSex(playerid,sex)
{
    if (s_AccountRegistrationStep[playerid] != ACCOUNT_STEP_SEX || (sex != 1 && sex != 2))
    {
        return false;
    }

    Account_SetSex(playerid,sex);
    SendClientMessage(playerid,COLOR_YELLOW2,sex == 1 ? "Ok, so you are a Male." : "Ok, so you are a Female.");
    SendClientMessage(playerid,COLOR_LIGHTRED,"What is your birthdate? (Use dd/mm/yyyy)");
    s_AccountRegistrationStep[playerid] = ACCOUNT_STEP_BIRTHDATE;
    Account_AskStep(playerid);
    return true;
}

stock bool:Account_AnswerBirthdate(playerid,const text[])
{
    if (s_AccountRegistrationStep[playerid] != ACCOUNT_STEP_BIRTHDATE)
    {
        return false;
    }

    new year, month, day, birthDay, birthMonth, birthYear;
    getdate(year,month,day);
    Account_ParseDate(text,birthDay,birthMonth,birthYear);

    if (year - birthYear > ACCOUNT_MAX_AGE || birthYear < 1 || birthYear >= year)
    {
        SendClientMessage(playerid,COLOR_LIGHTRED,"What is your Birthdate? (Use dd/mm/yyyy)");
        return false;
    }

    new age = year - birthYear;

    if (birthMonth > month)
    {
        age -= 1;
    }
    else if (birthMonth == month && birthDay > day)
    {
        age -= 1;
    }

    Account_SetAge(playerid,age);

    new line[64];
    format(line,sizeof(line),"Ok, so you are %d year old.",age);
    SendClientMessage(playerid,COLOR_YELLOW2,line);
    s_AccountRegistrationStep[playerid] = ACCOUNT_STEP_ORIGIN;
    SendClientMessage(playerid,COLOR_LIGHTRED,"What is your Origin? (Type in: USA, Europe or Asia)");
    Account_AskStep(playerid);
    return true;
}

static Account_FinishRegistration(playerid,origin,const confirmation[])
{
    Account_SetOrigin(playerid,origin);
    SendClientMessage(playerid,COLOR_YELLOW2,confirmation);
    SendClientMessage(playerid,COLOR_LIGHTRED,"Thank you for filling in all the information, now you will proceed to the Tutorial.");
    s_AccountRegistrationStep[playerid] = ACCOUNT_STEP_NONE;
    Account_ReleaseMenuChord(playerid);
    Account_AskStep(playerid);
    pawn_call_public("Account_OnRegistrationDone","d",playerid);
}

stock Account_AnswerOrigin(playerid,origin)
{
    if (s_AccountRegistrationStep[playerid] != ACCOUNT_STEP_ORIGIN)
    {
        return false;
    }

    switch (origin)
    {
        case 1:
        {
            Account_FinishRegistration(playerid,1,"Ok, so you are from the USA.");
        }
        case 2:
        {
            Account_FinishRegistration(playerid,2,"Ok, so you are from Europe.");
        }
        case 3:
        {
            Account_FinishRegistration(playerid,3,"Ok, so you are from Asia.");
        }
        default:
        {
            return false;
        }
    }

    return true;
}

static Account_StepSex(playerid,const text[])
{
    if (Account_FirstWordIs(text,"male"))
    {
        Account_AnswerSex(playerid,1);
        return;
    }

    if (Account_FirstWordIs(text,"female"))
    {
        Account_AnswerSex(playerid,2);
        return;
    }

    SendClientMessage(playerid,COLOR_LIGHTRED,"Are you a Male or Female? (Type in what you are).");
}

static Account_StepOrigin(playerid,const text[])
{
    if (Account_FirstWordIs(text,"usa"))
    {
        Account_AnswerOrigin(playerid,1);
        return;
    }

    if (Account_FirstWordIs(text,"europe"))
    {
        Account_AnswerOrigin(playerid,2);
        return;
    }

    if (Account_FirstWordIs(text,"asia"))
    {
        Account_AnswerOrigin(playerid,3);
        return;
    }

    SendClientMessage(playerid,COLOR_LIGHTRED,"What is your Origin? (Type in: USA, Europe or Asia)");
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
public Account_OnRegistrationStart(playerid)
{
    return 1;
}

public Account_OnRegistrationDone(playerid)
{
    return 1;
}

public Account_ChatMuted(playerid,const text[])
{
    #pragma unused text

    if (!Account_IsMuted(playerid))
    {
        return 0;
    }

    SendClientMessage(playerid,TEAM_CYAN_COLOR,"You cannot speak, you have been silenced");
    return 1;
}

public Account_ChatRegistration(playerid,const text[])
{
    switch (s_AccountRegistrationStep[playerid])
    {
        case ACCOUNT_STEP_SEX:
        {
            Account_StepSex(playerid,text);
        }
        case ACCOUNT_STEP_BIRTHDATE:
        {
            Account_AnswerBirthdate(playerid,text);
        }
        case ACCOUNT_STEP_ORIGIN:
        {
            Account_StepOrigin(playerid,text);
        }
        default:
        {
            return 0;
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
    s_AccountRegistrationStep[playerid] = ACCOUNT_STEP_NONE;
    s_AccountRegistrationBlocked[playerid] = false;
}

hook OnPlayerDisconnect(playerid,reason)
{
    Account_ReleaseMenuChord(playerid);
}
