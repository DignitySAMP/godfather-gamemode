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
static Missions_Ordinal(number,dest[],size = sizeof(dest))
{
    new suffix[3] = "th";

    if (number % 100 < 11 || number % 100 > 13)
    {
        switch (number % 10)
        {
            case 1:
            {
                suffix = "st";
            }
            case 2:
            {
                suffix = "nd";
            }
            case 3:
            {
                suffix = "rd";
            }
        }
    }

    format(dest,size,"%d%s",number,suffix);
}

static Missions_MakeText(playerid,const params[],at)
{
    new token[MISSIONS_INPUT_LEN], text[MISSIONS_INPUT_LEN], ordinal[8], line[MISSIONS_MESSAGE_LEN];
    if (!Missions_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /mk text [number] [text]");
        return;
    }

    new number = strval(token);

    if (number < 1 || number > MISSIONS_TEXTS)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Number can't be below 1 or above 18 !");
        return;
    }

    if (!Missions_ReadRest(params,at,text))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/mk text [number] [text]");
        return;
    }

    Missions_SetText(number - 1,text);
    Missions_Ordinal(number,ordinal);
    format(line,sizeof(line),"You've made the %s Text Line of the Mission.",ordinal);
    SendClientMessage(playerid,COLOR_WHITE,line);
}

static Missions_MakeGameText(playerid,const params[],at)
{
    new token[MISSIONS_INPUT_LEN], text[MISSIONS_INPUT_LEN], ordinal[8], line[MISSIONS_MESSAGE_LEN];
    if (!Missions_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /mk game [number] [text]");
        return;
    }

    new number = strval(token);

    if (number < 1 || number > MISSIONS_GAME_TEXTS)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Number can't be below 1 or above 6 !");
        return;
    }

    if (!Missions_ReadRest(params,at,text))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/mk game [number] [text]");
        return;
    }

    Missions_SetGameText(number - 1,text);
    Missions_Ordinal(number,ordinal);
    format(line,sizeof(line),"You've made the %s GameText Line of the Mission.",ordinal);
    SendClientMessage(playerid,COLOR_WHITE,line);
}

static Missions_MakePoint(playerid,const params[],at)
{
    new token[MISSIONS_INPUT_LEN], ordinal[8], line[MISSIONS_MESSAGE_LEN], Float:x, Float:y, Float:z;
    if (!Missions_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /mk cp [number]");
        return;
    }

    new number = strval(token);

    if (number < 1 || number > MISSIONS_POINTS)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Number can't be below 1 or above 6 !");
        return;
    }

    GetPlayerPos(playerid,x,y,z);
    Missions_SetPoint(number - 1,x,y,z);

    if (number == 1)
    {
        SendClientMessage(playerid,COLOR_WHITE,"You've made the 1st Checkpoint of the Mission.");
        return;
    }

    Missions_Ordinal(number,ordinal);
    format(line,sizeof(line),"You've made the %s Checkpoint Line of the Mission.",ordinal);
    SendClientMessage(playerid,COLOR_WHITE,line);
}

static Missions_MakeToggle(playerid,const params[],at)
{
    new token[MISSIONS_INPUT_LEN];
    if (!Missions_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /mk usecp [0/1]");
        return;
    }

    new toggle = strval(token);

    if (toggle != 0 && toggle != 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   CheckpointUse number must be 0 (OFF) or 1 (ON) !");
        return;
    }

    Missions_SetToggle(toggle);

    if (toggle == 0)
    {
        SendClientMessage(playerid,COLOR_WHITE,"You've set the Use of Checkpoints to 0 (OFF).");
    }
    else
    {
        SendClientMessage(playerid,COLOR_WHITE,"You've set the Use of Checkpoints to 1 (ON).");
    }
}

static Missions_MakeTitle(playerid,const params[],at)
{
    new text[MISSIONS_INPUT_LEN];

    if (!Missions_ReadRest(params,at,text))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/mk title [text]");
        return;
    }

    Missions_SetTitle(text);
    SendClientMessage(playerid,COLOR_WHITE,"You've made the Title of the Mission.");
}

static Missions_MakeReward(playerid,const params[],at)
{
    new token[MISSIONS_INPUT_LEN];
    if (!Missions_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /mk reward [price]");
        return;
    }

    new price = strval(token);

    if (price < 1 || price > MISSIONS_MAX_REWARD)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Reward Price can't be below 1 or above 50000 !");
        return;
    }

    Missions_SetReward(price);
    SendClientMessage(playerid,COLOR_WHITE,"You've made the Reward Price for the Mission.");
}

CMD<ADMIN_LEVEL_MANAGER>:mk(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, name[MISSIONS_INPUT_LEN];

    if (!Missions_ReadToken(params,at,name))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /mk [name]");
        SendClientMessage(playerid,COLOR_GREY,"Available names: (/mk text [number] [text]) (/mk game [number] [text]) (/mk cp [number])");
        SendClientMessage(playerid,COLOR_GREY,"Available names: (/mk title [text]) (/mk reward [price]) (/mk usecp)");
        return 1;
    }

    if (!strcmp(name,"text",true))
    {
        Missions_MakeText(playerid,params,at);
    }
    else if (!strcmp(name,"game",true))
    {
        Missions_MakeGameText(playerid,params,at);
    }
    else if (!strcmp(name,"cp",true))
    {
        Missions_MakePoint(playerid,params,at);
    }
    else if (!strcmp(name,"usecp",true))
    {
        Missions_MakeToggle(playerid,params,at);
    }
    else if (!strcmp(name,"title",true))
    {
        Missions_MakeTitle(playerid,params,at);
    }
    else if (!strcmp(name,"reward",true))
    {
        Missions_MakeReward(playerid,params,at);
    }
    else
    {
        SendClientMessage(playerid,COLOR_GREY,"   Invalid Mission Making name !");
    }

    return 1;
}

CMD<ADMIN_LEVEL_DEVELOPER>:savemission(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new name[MISSIONS_NAME_LEN];

    if (sscanf(params,"s[32]",name))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /savemission [missionname]");
        return 1;
    }

    Missions_Save(playerid,name);
    return 1;
}

CMD<ADMIN_LEVEL_DEVELOPER>:loadmission(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new name[MISSIONS_NAME_LEN];

    if (sscanf(params,"s[32]",name))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /loadmission [missionname]");
        return 1;
    }

    Missions_Load(playerid,name);
    return 1;
}

CMD:mission(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!Property_IsNear(playerid,MISSIONS_BOARD_RADIUS,MISSIONS_BOARD_X,MISSIONS_BOARD_Y,MISSIONS_BOARD_Z))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not at the Bill Board !");
        return 1;
    }

    if (Missions_GetPlayable() == 0)
    {
        SendClientMessage(playerid,COLOR_GREY,"   No Mission has been Activated !");
        return 1;
    }

    if (Missions_GetCompleted(playerid) == Missions_GetPlayable())
    {
        SendClientMessage(playerid,COLOR_GREY,"   You've already completed the Active Mission !");
        return 1;
    }

    Missions_Begin(playerid);
    return 1;
}
