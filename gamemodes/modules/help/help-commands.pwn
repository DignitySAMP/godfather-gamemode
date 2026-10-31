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
CMD:help(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new job = Help_ReadField(HELP_FIELD_JOB,playerid);
    new member = Help_ReadField(HELP_FIELD_MEMBER,playerid);
    new leader = Help_ReadField(HELP_FIELD_LEADER,playerid);
    new team = Account_GetTeam(playerid);

    SendClientMessage(playerid,COLOR_GRAD1,"*** ACCOUNT *** /rules /login /stats /buylevel /upgrade");
    SendClientMessage(playerid,COLOR_GRAD2,"*** GENERAL *** /pay /charity /time /buy /unrentcar /givekey /switchkey /id /drink /music /showlicenses /clothes");
    SendClientMessage(playerid,COLOR_GRAD2,"*** GENERAL *** /resetupgrades(100k) /buygun /lock /skill /portable /licenses /lotto /spawnchange /stopani");
    SendClientMessage(playerid,COLOR_GRAD2,"*** GENERAL *** /report /cancel /accept /eject /usedrugs /contract /fill /fillcar /clear /service /families");
    SendClientMessage(playerid,COLOR_GRAD3,"*** CHAT *** (/w)hisper (/o)oc (/s)hout (/c)lose (/l)ocal (/b) (/ad)vertise (/f)amily /me /togooc /tognews /togfam /togwhisper /fuel");
    SendClientMessage(playerid,COLOR_GRAD4,"*** BANK *** /balance /withdraw /deposit /wiretransfer");

    if (job == 1)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** JOB *** /find");
    }
    else if (job == 2)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** JOB *** /free");
    }
    else if (job == 3)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** JOB *** /sex");
    }
    else if (job == 4)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** JOB *** /selldrugs");
    }
    else if (job == 5)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** JOB *** /dropcar");
    }
    else if (member == 9)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** JOB *** /paper /papers /live /news [text]");
    }
    else if (job == 7)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** JOB *** /repair /refill /duty");
    }
    else if (job == 8)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** JOB *** /guard");
    }
    else if (job == 9)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** JOB *** /materials /sellgun");
    }
    else if (job == 10)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** JOB *** /sellcar");
    }
    else if (job == 12)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** JOB *** /fight /boxstats");
    }
    else if (member == 10 || leader == 10 || job == 14)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** JOB *** /fare");
    }
    else if (job == 15)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** JOB *** /papers /bring /deliver");
    }

    if (member == 11 || leader == 11 || member == 12 || leader == 12)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** LESSON *** /startlesson /stoplesson /givelicense");
    }

    if (team == 2)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** SAPD *** (/r)adio (/d)epartments (/m)egaphone (/su)spect /mdc /arrest /duty /wanted /cuff /tazer");
        SendClientMessage(playerid,COLOR_GRAD5,"*** SAPD *** /frisk /take /ticket (/gov)ernment /deliver /camera /ram");
    }

    if (team == 1 || member == 4 || leader == 4)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** SAMD *** (/r)adio (/d)epartments /heal /duty");
    }

    if (Account_GetAdminLevel(playerid) >= 1)
    {
        SendClientMessage(playerid,COLOR_GRAD6,"*** ADMIN *** (/a)dmin (/ah)elp");
    }

    SendClientMessage(playerid,COLOR_GRAD6,"*** OTHER *** /cellphonehelp /househelp /renthelp /businesshelp /leaderhelp /fishhelp /cookhelp /irchelp");
    return 1;
}

CMD:rules(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_LIGHTRED,"INFO: Read our forum for all our rules and information.");
    return 1;
}

CMD:cellphonehelp(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_GREEN,HELP_SEPARATOR);

    if (Help_ReadField(HELP_FIELD_PHONE,playerid) > 0)
    {
        SendClientMessage(playerid,COLOR_WHITE,"*** HELP *** type a command for more help");
        SendClientMessage(playerid,COLOR_GRAD3,"*** CELLPHONE *** /call 'eg: /call 911' /sms (/p)ickup (/h)angup /number");
        SendClientMessage(playerid,COLOR_GRAD4,"*** OTHER *** /help /househelp /renthelp /businesshelp /leaderhelp /fishhelp /cookhelp /irchelp");
        return 1;
    }

    SendClientMessage(playerid,COLOR_WHITE,"You can buy a cell phone in any 24-7");
    return 1;
}

CMD:househelp(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_GREEN,HELP_SEPARATOR);
    SendClientMessage(playerid,COLOR_WHITE,"*** HOUSE HELP *** type a command for more help");
    SendClientMessage(playerid,COLOR_GRAD3,"*** HOUSE *** /enter /exit /open /home /heal /houseupgrade (/hu) /setrentable /tv (off/player)");
    SendClientMessage(playerid,COLOR_GRAD3,"*** HOUSE *** /carupgrade /carcolor /evictall /towcar /fixcar /setrent /evict /housewithdraw");
    SendClientMessage(playerid,COLOR_GRAD4,"*** OTHER *** /cellphonehelp /help /renthelp /businesshelp /leaderhelp /fishhelp /cookhelp /irchelp");
    return 1;
}

CMD:renthelp(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_GREEN,HELP_SEPARATOR);
    SendClientMessage(playerid,COLOR_WHITE,"*** RENTING HELP *** type a command for more help");
    SendClientMessage(playerid,COLOR_GRAD3,"*** RENT *** /unrent /enter /exit /lock /home");
    SendClientMessage(playerid,COLOR_GRAD4,"*** OTHER *** /cellphonehelp /househelp /help /businesshelp /leaderhelp /fishhelp /cookhelp /irchelp");
    return 1;
}

CMD:businesshelp(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_GREEN,HELP_SEPARATOR);
    SendClientMessage(playerid,COLOR_WHITE,"*** BUSINESS HELP *** type a command for more help");
    SendClientMessage(playerid,COLOR_GRAD3,"*** BUSINESS *** /bizinfo /bizfee /bizname /prodprice /extortion");
    SendClientMessage(playerid,COLOR_GRAD4,"*** BUSINESS *** /enter /exit /open /sellbiz /bizbank /bizwithdraw");
    SendClientMessage(playerid,COLOR_GRAD4,"*** OTHER *** /cellphonehelp /househelp /renthelp /help");
    return 1;
}

CMD:leaderhelp(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new leader = Help_ReadField(HELP_FIELD_LEADER,playerid);

    if (leader < 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Leader!");
        return 1;
    }

    SendClientMessage(playerid,COLOR_GREEN,HELP_SEPARATOR);
    SendClientMessage(playerid,COLOR_WHITE,"*** LEADER HELP *** type a command for more help");
    SendClientMessage(playerid,COLOR_GRAD3,"*** LEADERS *** /invite /uninvite /giverank");

    if (leader == 5 || leader == 6)
    {
        SendClientMessage(playerid,COLOR_GRAD3,"*** LEADERS *** /allowcreation /deletecreation /giveturf");
    }

    if (leader == 7)
    {
        SendClientMessage(playerid,COLOR_GRAD3,"*** LEADERS *** /settax /givetax (Give some money to the Cops)");
    }

    SendClientMessage(playerid,COLOR_GREEN,HELP_SEPARATOR);
    return 1;
}

CMD:irchelp(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_GREEN,HELP_SEPARATOR);
    SendClientMessage(playerid,COLOR_WHITE,"*** IRC HELP *** Type a command for more help");
    SendClientMessage(playerid,COLOR_WHITE,"*** IRC *** (/irc join [channelnr] or /irc join [channelnr] [password])  (/irc leave)");
    SendClientMessage(playerid,COLOR_WHITE,"*** IRC *** (/irc Password [channelnr])  (/irc NeedPass [channelnr])  (/irc Lock [channelnr])");
    SendClientMessage(playerid,COLOR_WHITE,"*** IRC *** (/irc Admins)  (/irc MOTD [motdtext])  (/irc status [channelnr])  (/i [text])");
    return 1;
}

CMD:fishhelp(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_GREEN,HELP_SEPARATOR);
    SendClientMessage(playerid,COLOR_WHITE,"*** FISH HELP *** type a command for more help");
    SendClientMessage(playerid,COLOR_GRAD3,"*** FISHING *** /fish (Try to catch a fish)   /fishes (Show the fishes you have caught)");
    SendClientMessage(playerid,COLOR_GRAD3,"*** FISHING *** /throwback (Throw the last fish you caught back)   /throwbackall");
    SendClientMessage(playerid,COLOR_GRAD3,"*** FISHING *** /releasefish (Release one of your fishes)");
    return 1;
}

CMD:cookhelp(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_GREEN,HELP_SEPARATOR);
    SendClientMessage(playerid,COLOR_WHITE,"*** COOK HELP *** type a command for more help");
    SendClientMessage(playerid,COLOR_GRAD3,"*** COOKING *** /cook (See all the options available)   /cooked (See everything that you have Cooked)");
    SendClientMessage(playerid,COLOR_GRAD3,"*** COOKING *** /eat (Eat something that you have Cooked)");
    return 1;
}

CMD:ahelp(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new level = Account_GetAdminLevel(playerid);

    SendClientMessage(playerid,COLOR_GREEN,HELP_SEPARATOR);

    if (level >= 1)
    {
        SendClientMessage(playerid,COLOR_GRAD1,"*1* TRIAL *** /check /setint /mute /slap /kick /skick /kickres /warn /sban /ban /unfreeze /goto /cnn");
        SendClientMessage(playerid,COLOR_GRAD1,"*1* TRIAL *** /a(dmin) chat /up /dn /lt /rt /fly");
    }

    if (level >= 2)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"*2* MODERATOR *** /skydive /setteam /bigears /freeze /recon /jail /prison");
    }

    if (level >= 3)
    {
        SendClientMessage(playerid,COLOR_GRAD3,"*3* ADMIN *** /noooc /endround /cks /gotols /gotolv /gotosf /gotoin /gotostad /gotojet");
        SendClientMessage(playerid,COLOR_GRAD4,"*3* ADMIN *** /mark /gotomark /gethere /entercar /gotocar /getcar");
    }

    if (level >= 4)
    {
        SendClientMessage(playerid,COLOR_GRAD4,"*4* MANAGER *** /mole /hq /logout /logoutpl /logoutall /edit /fuelcars /asellhouse /asellbiz /asellsbiz /setchamp /mk");
        SendClientMessage(playerid,COLOR_GRAD4,"*4* MANAGER *** /veh /fixveh /destroycars /sethp /setarmor /givegun /givemoney /money(sets money) /forceskin /setstat /setfamily");
        SendClientMessage(playerid,COLOR_GRAD4,"*4* MANAGER *** /createhouse /createbiz /movehouse /movebiz /deletehouse /deletebiz /nearestinterior /edithousecar");
    }

    if (level >= 1337)
    {
        SendClientMessage(playerid,COLOR_GRAD5,"*** 1337+ *** /weather /weatherall /makeadmin /makeleader /tod /savemission /loadmission /startlotto /fourdive /cnnn /gmx");
        SendClientMessage(playerid,COLOR_GRAD5,"*** 1337+ *** /house /houseo /biz /sbiz /resethousecars /makeircadmin /hirecar");
    }

    if (level >= 1338)
    {
        SendClientMessage(playerid,COLOR_GRAD6,"***1338 This makes you invisible in the admin list");
    }

    SendClientMessage(playerid,COLOR_GREEN,HELP_SEPARATOR);
    return 1;
}

ALT:ah=CMD:ahelp;
