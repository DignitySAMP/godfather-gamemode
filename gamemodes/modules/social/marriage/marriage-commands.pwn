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
CMD:divorce(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Marriage_IsMarried(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You aren't Married !");
        return 1;
    }

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /divorce [Playerid/PartOfName]");
        return 1;
    }

    if (!Util_IsValidPlayer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,MARRIAGE_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"You cannot Divorce yourself!");
        return 1;
    }

    new name[MARRIAGE_NAME_LEN], senderName[MARRIAGE_NAME_LEN], line[MARRIAGE_LINE_LEN];
    GetPlayerName(targetid,name,sizeof(name));
    GetPlayerName(playerid,senderName,sizeof(senderName));

    if (!Marriage_IsSpouseName(playerid,name))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not Married to you !");
        return 1;
    }

    format(line,sizeof(line),"* You've sent Divorce Papers to %s.",name);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s just sent you his Divorce Papers (type /accept divorce) to accept.",senderName);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    Marriage_SetDivorceOffer(targetid,playerid);
    return 1;
}

CMD:propose(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (Account_GetCash(playerid) < MARRIAGE_COST)
    {
        SendClientMessage(playerid,COLOR_GREY,"   The Marriage & Reception costs $100000 !");
        return 1;
    }

    if (Marriage_IsMarried(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are already Married !");
        return 1;
    }

    if (Houses_GetKey(playerid) == HOUSE_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You don't have a House to let your Wife / Husband live somewhere !");
        return 1;
    }

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /propose [Playerid/PartOfName]");
        return 1;
    }

    if (!Util_IsValidPlayer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    if (Marriage_IsMarried(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is already Married !");
        return 1;
    }

    if (Houses_GetKey(targetid) != HOUSE_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player has a House, can't be Married !");
        return 1;
    }

    if (Business_GetKey(targetid) != BUSINESS_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player has a Business, can't be Married !");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,MARRIAGE_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"You cannot Propose to yourself!");
        return 1;
    }

    new name[MARRIAGE_NAME_LEN], senderName[MARRIAGE_NAME_LEN], line[MARRIAGE_LINE_LEN];
    GetPlayerName(targetid,name,sizeof(name));
    GetPlayerName(playerid,senderName,sizeof(senderName));
    format(line,sizeof(line),"* You proposed to %s.",name);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s just proposed to you (type /accept marriage) to accept.",senderName);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    Marriage_SetProposeOffer(targetid,playerid);
    return 1;
}

CMD:witness(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /witness [Playerid/PartOfName]");
        return 1;
    }

    if (!Util_IsValidPlayer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,MARRIAGE_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"You cannot Witness yourself!");
        return 1;
    }

    new name[MARRIAGE_NAME_LEN], senderName[MARRIAGE_NAME_LEN], line[MARRIAGE_LINE_LEN];
    GetPlayerName(targetid,name,sizeof(name));
    GetPlayerName(playerid,senderName,sizeof(senderName));
    format(line,sizeof(line),"* You requested %s to be your Marriage Witness.",name);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s just requested you to be his Marriage Witness (type /accept witness) to accept.",senderName);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    Marriage_SetWitnessOffer(targetid,playerid);
    return 1;
}

static Marriage_TakeSharedKeys(first,second)
{
    new house = Houses_GetKey(first);

    if (house != HOUSE_NO_KEY && house == Houses_GetKey(second))
    {
        new bool:firstOwns = Houses_IsOwner(first,house), bool:secondOwns = Houses_IsOwner(second,house);

        if (firstOwns && !secondOwns)
        {
            Houses_SetKey(second,HOUSE_NO_KEY);
        }
        else if (secondOwns && !firstOwns)
        {
            Houses_SetKey(first,HOUSE_NO_KEY);
        }
    }

    new business = Business_GetKey(first);

    if (business != BUSINESS_NO_KEY && business == Business_GetKey(second))
    {
        new bool:firstOwns = Business_IsOwner(first,business), bool:secondOwns = Business_IsOwner(second,business);

        if (firstOwns && !secondOwns)
        {
            Business_SetKey(second,BUSINESS_NO_KEY);
        }
        else if (secondOwns && !firstOwns)
        {
            Business_SetKey(first,BUSINESS_NO_KEY);
        }
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
public Marriage_AcceptWitness(playerid,const params[])
{
    new requester = Marriage_GetWitnessOffer(playerid);

    if (requester == OFFER_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   No-one asked you to be his Marriage Witness !");
        return 1;
    }

    if (!Util_IsValidPlayer(requester))
    {
        return 1;
    }

    if (!Util_IsNear(playerid,requester,MARRIAGE_ACCEPT_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   The player that requested you to be his Marriage Witness is not near you !");
        return 1;
    }

    new name[MARRIAGE_NAME_LEN], requesterName[MARRIAGE_NAME_LEN], line[MARRIAGE_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(requester,requesterName,sizeof(requesterName));
    format(line,sizeof(line),"* You have accepted %s's request to be his Marriage Witness.",requesterName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s has accepted your request to be your Marriage Witness.",name);
    SendClientMessage(requester,COLOR_LIGHTBLUE,line);
    Marriage_SetWitness(requester,playerid);
    Marriage_SetWitnessOffer(playerid,OFFER_NONE);
    return 1;
}

public Marriage_CancelWitness(playerid,const params[])
{
    Marriage_SetWitnessOffer(playerid,OFFER_NONE);
    return 1;
}

public Marriage_AcceptMarriage(playerid,const params[])
{
    new proposer = Marriage_GetProposeOffer(playerid);

    if (proposer == OFFER_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   No-one Proposed to you !");
        return 1;
    }

    if (!Property_IsNear(playerid,MARRIAGE_CHURCH_RADIUS,MARRIAGE_CHURCH_X,MARRIAGE_CHURCH_Y,MARRIAGE_CHURCH_Z))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not at the Church in San Fierro !");
        return 1;
    }

    if (!Util_IsValidPlayer(proposer))
    {
        return 1;
    }

    if (!Util_IsNear(playerid,proposer,MARRIAGE_ACCEPT_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   The player that proposed to you is not near you !");
        return 1;
    }

    new witness = Marriage_GetWitness(proposer);

    if (witness == OFFER_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   The proposer doesn't have a Marriage Witness !");
        return 1;
    }

    if (!Util_IsValidPlayer(witness))
    {
        return 1;
    }

    if (!Util_IsNear(proposer,witness,MARRIAGE_WITNESS_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   The Marriage Witness is not near your proposer !");
        return 1;
    }

    new name[MARRIAGE_NAME_LEN], proposerName[MARRIAGE_NAME_LEN], line[MARRIAGE_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(proposer,proposerName,sizeof(proposerName));
    format(line,sizeof(line),"* You have accepted %s's request to be your Husband.",proposerName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s has accepted your request to be your Wife.",name);
    SendClientMessage(proposer,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"Priest: %s do you take %s as your lovely Husband? (type 'yes', anything else will reject the Marriage)",name,proposerName);
    SendClientMessage(playerid,COLOR_WHITE,line);
    Marriage_BeginCeremony(playerid,proposer);
    return 1;
}

public Marriage_CancelMarriage(playerid,const params[])
{
    Marriage_SetProposeOffer(playerid,OFFER_NONE);
    return 1;
}

public Marriage_AcceptDivorce(playerid,const params[])
{
    new sender = Marriage_GetDivorceOffer(playerid);

    if (sender == OFFER_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   No-one sent you any Divorce Papers !");
        return 1;
    }

    if (!Util_IsValidPlayer(sender))
    {
        return 1;
    }

    if (!Util_IsNear(playerid,sender,MARRIAGE_ACCEPT_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   The player that sent you the Divorce Papers is not near you !");
        return 1;
    }

    new name[MARRIAGE_NAME_LEN], senderName[MARRIAGE_NAME_LEN], line[MARRIAGE_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(sender,senderName,sizeof(senderName));
    format(line,sizeof(line),"* You have accepted %s's Divorce Papers.",senderName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s has accepted your Divorce Papers.",name);
    SendClientMessage(sender,COLOR_LIGHTBLUE,line);
    Marriage_TakeSharedKeys(playerid,sender);
    Marriage_Clear(playerid);
    Marriage_Clear(sender);
    return 1;
}

public Marriage_CancelDivorce(playerid,const params[])
{
    Marriage_SetDivorceOffer(playerid,OFFER_NONE);
    return 1;
}
