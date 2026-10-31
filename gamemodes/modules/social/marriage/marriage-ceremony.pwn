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
static Marriage_Pronounce(proposer,proposed)
{
    new proposerName[MARRIAGE_NAME_LEN], proposedName[MARRIAGE_NAME_LEN], line[MARRIAGE_LINE_LEN];
    new proposerSex = Account_GetSex(proposer), proposedSex = Account_GetSex(proposed);
    GetPlayerName(proposer,proposerName,sizeof(proposerName));
    GetPlayerName(proposed,proposedName,sizeof(proposedName));

    if (proposerSex == MARRIAGE_SEX_MALE && proposedSex == MARRIAGE_SEX_FEMALE)
    {
        format(line,sizeof(line),"Priest: %s and %s I pronounce you now...Husband & Wife, you may kiss the Bride.",proposerName,proposedName);
        SendClientMessage(proposer,COLOR_WHITE,line);
        format(line,sizeof(line),"Priest: %s and %s I pronounce you now...Husband & Wife, you may kiss the Groom.",proposedName,proposerName);
        SendClientMessage(proposed,COLOR_WHITE,line);
        format(line,sizeof(line),"Marriage News: We have a new lovely couple, %s & %s have been married.",proposerName,proposedName);
        News_Send(COLOR_WHITE,line);
    }
    else if (proposerSex == MARRIAGE_SEX_FEMALE && proposedSex == MARRIAGE_SEX_MALE)
    {
        format(line,sizeof(line),"Priest: %s and %s I pronounce you now...Husband & Wife, you may kiss the Groom.",proposerName,proposedName);
        SendClientMessage(proposer,COLOR_WHITE,line);
        format(line,sizeof(line),"Priest: %s and %s I pronounce you now...Husband & Wife, you may kiss the Bride.",proposedName,proposerName);
        SendClientMessage(proposed,COLOR_WHITE,line);
        format(line,sizeof(line),"Marriage News: We have a new lovely couple, %s & %s have been married.",proposerName,proposedName);
        News_Send(COLOR_WHITE,line);
    }
    else if (proposerSex == MARRIAGE_SEX_MALE && proposedSex == MARRIAGE_SEX_MALE)
    {
        format(line,sizeof(line),"Priest: %s and %s I pronounce you now...Husband & Husband, you may kiss the Bride.",proposerName,proposedName);
        SendClientMessage(proposer,COLOR_WHITE,line);
        format(line,sizeof(line),"Priest: %s and %s I pronounce you now...Husband & Husband, you may kiss the Groom.",proposedName,proposerName);
        SendClientMessage(proposed,COLOR_WHITE,line);
        format(line,sizeof(line),"Marriage News: We have a new Gay couple, %s & %s have been married.",proposerName,proposedName);
        News_Send(COLOR_WHITE,line);
    }
    else if (proposerSex == MARRIAGE_SEX_FEMALE && proposedSex == MARRIAGE_SEX_FEMALE)
    {
        format(line,sizeof(line),"Priest: %s and %s I pronounce you now...Wife & Wife, you may kiss the Bride.",proposerName,proposedName);
        SendClientMessage(proposer,COLOR_WHITE,line);
        format(line,sizeof(line),"Priest: %s and %s I pronounce you now...Wife & Wife, you may kiss the Groom.",proposedName,proposerName);
        SendClientMessage(proposed,COLOR_WHITE,line);
        format(line,sizeof(line),"Marriage News: We have a new Lesbian couple, %s & %s have been married.",proposerName,proposedName);
        News_Send(COLOR_WHITE,line);
    }
}

static Marriage_Finish(proposer,proposed)
{
    new proposerName[MARRIAGE_NAME_LEN], proposedName[MARRIAGE_NAME_LEN];
    GetPlayerName(proposer,proposerName,sizeof(proposerName));
    GetPlayerName(proposed,proposedName,sizeof(proposedName));

    Marriage_Pronounce(proposer,proposed);
    Marriage_ClearCeremony(proposer);
    Marriage_ClearCeremony(proposed);
    Marriage_Store(proposed,true,proposerName);
    Marriage_Store(proposer,true,proposedName);
    Account_SetCash(proposer,Account_GetCash(proposer) - MARRIAGE_COST);
    Houses_SetKey(proposed,Houses_GetKey(proposer));
    Business_SetKey(proposed,Business_GetKey(proposer));
}

static Marriage_Refuse(playerid,partner)
{
    new name[MARRIAGE_NAME_LEN], partnerName[MARRIAGE_NAME_LEN], line[MARRIAGE_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(partner,partnerName,sizeof(partnerName));
    format(line,sizeof(line),"* You didn't want to Marry %s, no 'yes' was said.",partnerName);
    SendClientMessage(playerid,COLOR_YELLOW,line);
    format(line,sizeof(line),"* %s didn't want to Marry you, no 'yes' was said.",name);
    SendClientMessage(partner,COLOR_YELLOW,line);
    Marriage_ClearCeremony(playerid);
    Marriage_ClearCeremony(partner);
}

stock Marriage_HandleCeremonyText(playerid,const text[])
{
    if (!Marriage_IsInCeremony(playerid))
    {
        return 0;
    }

    new token[MARRIAGE_TOKEN_LEN], bool:isYes = false;

    if (Util_FirstWord(text,token) > 0 && !strcmp(token,"yes",true))
    {
        isYes = true;
    }

    new proposer = Marriage_GetGotProposedBy(playerid), proposed = Marriage_GetProposedTo(playerid);

    if (proposer != OFFER_NONE)
    {
        if (!Util_IsValidPlayer(proposer))
        {
            Marriage_ClearCeremony(playerid);
            return 1;
        }

        if (!isYes)
        {
            Marriage_Refuse(playerid,proposer);
            return 1;
        }

        new name[MARRIAGE_NAME_LEN], proposerName[MARRIAGE_NAME_LEN], line[MARRIAGE_LINE_LEN];
        GetPlayerName(playerid,name,sizeof(name));
        GetPlayerName(proposer,proposerName,sizeof(proposerName));
        format(line,sizeof(line),"Priest: %s do you take %s as your lovely Wife? (type 'yes', anything else will reject the Marriage).",proposerName,name);
        SendClientMessage(proposer,COLOR_WHITE,line);
        Marriage_PassCeremony(playerid,proposer);
        return 0;
    }

    if (proposed != OFFER_NONE)
    {
        if (!Util_IsValidPlayer(proposed))
        {
            Marriage_ClearCeremony(playerid);
            return 1;
        }

        if (!isYes)
        {
            Marriage_Refuse(playerid,proposed);
            return 1;
        }

        Marriage_Finish(playerid,proposed);
        return 0;
    }

    Marriage_ClearCeremony(playerid);
    return 1;
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
public Marriage_ChatCeremony(playerid,const text[])
{
    return Marriage_HandleCeremonyText(playerid,text);
}
