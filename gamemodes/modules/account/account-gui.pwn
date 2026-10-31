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
#define ACCOUNT_GUI_TEXT_LEN (129)

static s_AccountAuthEpoch[MAX_PLAYERS];
static s_AccountAskEpoch[MAX_PLAYERS];
static bool:s_AccountAuthDialogOpen[MAX_PLAYERS];
static bool:s_AccountViaDialog[MAX_PLAYERS];
static bool:s_AccountAskDialogOpen[MAX_PLAYERS];
static bool:s_AccountAskMenuOpen[MAX_PLAYERS];

forward Account_AuthDeferred(playerid);
forward Account_BirthdateDeferred(playerid);
forward Account_SexMenuPick(playerid,response,listitem,const name[],value);
forward Account_OriginMenuPick(playerid,response,listitem,const name[],value);
forward Account_RequestLogin(playerid,const password[]);
forward Account_RequestRegister(playerid,const password[]);
forward Account_SendPrompt(playerid);

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
stock Account_AttemptText(result,dest[],size = sizeof(dest))
{
    switch (result)
    {
        case ACCOUNT_ATTEMPT_LOGGED_IN:
        {
            strcopy(dest,ACCOUNT_REPLY_LOGGED_IN,size);
        }
        case ACCOUNT_ATTEMPT_TAKEN:
        {
            strcopy(dest,ACCOUNT_REPLY_TAKEN,size);
        }
        case ACCOUNT_ATTEMPT_COOLDOWN:
        {
            strcopy(dest,ACCOUNT_REPLY_COOLDOWN,size);
        }
        case ACCOUNT_ATTEMPT_TOO_SHORT:
        {
            format(dest,size,"SERVER: Your password must be at least %d characters long.",ACCOUNT_PASSWORD_MIN);
        }
        case ACCOUNT_ATTEMPT_TOO_LONG:
        {
            format(dest,size,"SERVER: Your password can be at most %d characters long.",ACCOUNT_PASSWORD_MAX);
        }
        case ACCOUNT_ATTEMPT_HAS_SPACE:
        {
            strcopy(dest,ACCOUNT_REPLY_HAS_SPACE,size);
        }
        default:
        {
            dest[0] = EOS;
        }
    }
}

stock Account_CheckPassword(const password[])
{
    new length = strlen(password);

    if (length < ACCOUNT_PASSWORD_MIN)
    {
        return ACCOUNT_ATTEMPT_TOO_SHORT;
    }

    if (length > ACCOUNT_PASSWORD_MAX)
    {
        return ACCOUNT_ATTEMPT_TOO_LONG;
    }

    if (strfind(password," ") != -1)
    {
        return ACCOUNT_ATTEMPT_HAS_SPACE;
    }

    return ACCOUNT_ATTEMPT_STARTED;
}

stock Account_CloseAuthDialog(playerid)
{
    s_AccountAuthEpoch[playerid]++;
    s_AccountViaDialog[playerid] = false;

    if (s_AccountAuthDialogOpen[playerid])
    {
        s_AccountAuthDialogOpen[playerid] = false;
        HidePlayerDialog(playerid);
    }
}

stock Account_ShowAuthDialog(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || IsPlayerNPC(playerid))
    {
        return;
    }

    SetTimerEx("Account_AuthDeferred",0,false,"d",playerid);
}

stock Account_RetryAuthDialog(playerid)
{
    if (!s_AccountViaDialog[playerid])
    {
        return;
    }

    s_AccountViaDialog[playerid] = false;
    Account_ShowAuthDialog(playerid);
}

static Account_AuthFlow(playerid)
{
    yield 1;

    new epoch = ++s_AccountAuthEpoch[playerid], password[ACCOUNT_GUI_TEXT_LEN], repeat[ACCOUNT_GUI_TEXT_LEN], body[256], error[96];

    for (;;)
    {
        new E_ACCOUNT_AUTH:authState = Account_GetAuthState(playerid);

        if (!IsPlayerConnected(playerid) || (authState != ACCOUNT_AUTH_UNREGISTERED && authState != ACCOUNT_AUTH_REGISTERED))
        {
            return;
        }

        new bool:isLogin = Account_Exists(playerid);

        if (isLogin)
        {
            format(body,sizeof(body),"That nick is registered, please login\n\nEnter your password below.");
        }
        else
        {
            format(body,sizeof(body),"You don't have an account.\n\nChoose a password of %d to %d characters, without spaces.",ACCOUNT_PASSWORD_MIN,ACCOUNT_PASSWORD_MAX);
        }

        if (error[0] != EOS)
        {
            strcat(body,"\n\n",sizeof(body));
            strcat(body,error,sizeof(body));
        }

        s_AccountAuthDialogOpen[playerid] = true;
        await_arr(password) ShowAsyncPasswordDialog(playerid,isLogin ? "Login" : "Register",body,isLogin ? "Login" : "Register","Cancel");

        if (!IsPlayerConnected(playerid) || s_AccountAuthEpoch[playerid] != epoch)
        {
            return;
        }

        s_AccountAuthDialogOpen[playerid] = false;

        if (isnull(password))
        {
            Account_SendPrompt(playerid);
            return;
        }

        if (!isLogin)
        {
            new check = Account_CheckPassword(password);

            if (check != ACCOUNT_ATTEMPT_STARTED)
            {
                Account_AttemptText(check,error);
                SendClientMessage(playerid,COLOR_WHITE,error);
                password[0] = EOS;
                continue;
            }
            s_AccountAuthDialogOpen[playerid] = true;
            await_arr(repeat) ShowAsyncPasswordDialog(playerid,"Repeat your password","Type the same password again.","Register","Back");

            if (!IsPlayerConnected(playerid) || s_AccountAuthEpoch[playerid] != epoch)
            {
                return;
            }

            s_AccountAuthDialogOpen[playerid] = false;
            error[0] = EOS;

            if (strcmp(repeat,password) != 0)
            {
                if (!isnull(repeat))
                {
                    strcopy(error,ACCOUNT_REPLY_MISMATCH);
                    SendClientMessage(playerid,COLOR_WHITE,error);
                }

                password[0] = EOS;
                repeat[0] = EOS;
                continue;
            }

            repeat[0] = EOS;
        }

        s_AccountViaDialog[playerid] = true;
        new result = isLogin ? Account_RequestLogin(playerid,password) : Account_RequestRegister(playerid,password);
        password[0] = EOS;

        if (result == ACCOUNT_ATTEMPT_STARTED)
        {
            return;
        }

        s_AccountViaDialog[playerid] = false;

        if (result == ACCOUNT_ATTEMPT_LOGGED_IN || result == ACCOUNT_ATTEMPT_BUSY)
        {
            return;
        }

        Account_AttemptText(result,error);
    }
}

stock Account_CloseQuestionUI(playerid)
{
    s_AccountAskEpoch[playerid]++;

    if (s_AccountAskDialogOpen[playerid])
    {
        s_AccountAskDialogOpen[playerid] = false;
        HidePlayerDialog(playerid);
    }

    if (s_AccountAskMenuOpen[playerid])
    {
        s_AccountAskMenuOpen[playerid] = false;

        if (Menubox_IsOpen(playerid))
        {
            Menubox_Hide(playerid);
        }
    }
}

static Account_ShowMenu(playerid,const title[],const callback[],const first[],const second[],const third[] = "")
{
    Menubox_Clear(playerid);
    Menubox_AddItem(playerid,first,1);
    Menubox_AddItem(playerid,second,2);

    if (third[0] != EOS)
    {
        Menubox_AddItem(playerid,third,3);
    }

    s_AccountAskMenuOpen[playerid] = Menubox_Show(playerid,title,callback);
}

stock Account_AskStep(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid))
    {
        return;
    }

    Account_CloseQuestionUI(playerid);

    switch (Account_GetRegistrationStep(playerid))
    {
        case ACCOUNT_STEP_SEX:
        {
            Account_ShowMenu(playerid,"Are you a Male or Female?","Account_SexMenuPick","Male","Female");
        }
        case ACCOUNT_STEP_BIRTHDATE:
        {
            SetTimerEx("Account_BirthdateDeferred",0,false,"d",playerid);
        }
        case ACCOUNT_STEP_ORIGIN:
        {
            Account_ShowMenu(playerid,"What is your Origin?","Account_OriginMenuPick","USA","Europe","Asia");
        }
    }
}

static Account_BirthdateFlow(playerid)
{
    yield 1;

    new epoch = ++s_AccountAskEpoch[playerid], text[ACCOUNT_GUI_TEXT_LEN], bool:isRetry = false;

    for (;;)
    {
        s_AccountAskDialogOpen[playerid] = true;
        await_arr(text) ShowAsyncStringInputDialog(playerid,"Your birthdate",isRetry ? "What is your Birthdate? (Use dd/mm/yyyy)" : "What is your birthdate? (Use dd/mm/yyyy)","Continue","Cancel");

        if (!IsPlayerConnected(playerid) || s_AccountAskEpoch[playerid] != epoch || Account_GetRegistrationStep(playerid) != ACCOUNT_STEP_BIRTHDATE)
        {
            return;
        }

        s_AccountAskDialogOpen[playerid] = false;

        if (isnull(text))
        {
            return;
        }

        if (Account_AnswerBirthdate(playerid,text))
        {
            return;
        }

        isRetry = true;
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
public Account_AuthDeferred(playerid)
{
    if (IsPlayerConnected(playerid) && !Account_IsLoggedIn(playerid))
    {
        Account_AuthFlow(playerid);
    }

    return 1;
}

public Account_BirthdateDeferred(playerid)
{
    if (IsPlayerConnected(playerid) && Account_GetRegistrationStep(playerid) == ACCOUNT_STEP_BIRTHDATE)
    {
        Account_BirthdateFlow(playerid);
    }

    return 1;
}

public Account_SexMenuPick(playerid,response,listitem,const name[],value)
{
    #pragma unused listitem, name

    s_AccountAskMenuOpen[playerid] = false;

    if (response)
    {
        Account_AnswerSex(playerid,value);
    }

    return 1;
}

public Account_OriginMenuPick(playerid,response,listitem,const name[],value)
{
    #pragma unused listitem, name

    s_AccountAskMenuOpen[playerid] = false;

    if (response)
    {
        Account_AnswerOrigin(playerid,value);
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
    s_AccountAuthEpoch[playerid]++;
    s_AccountAskEpoch[playerid]++;
    s_AccountAuthDialogOpen[playerid] = false;
    s_AccountViaDialog[playerid] = false;
    s_AccountAskDialogOpen[playerid] = false;
    s_AccountAskMenuOpen[playerid] = false;
}

hook OnPlayerDisconnect(playerid,reason)
{
    s_AccountAuthEpoch[playerid]++;
    s_AccountAskEpoch[playerid]++;
    s_AccountAuthDialogOpen[playerid] = false;
    s_AccountViaDialog[playerid] = false;
    s_AccountAskDialogOpen[playerid] = false;
    s_AccountAskMenuOpen[playerid] = false;
}
