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
#define HINTS_MAX (64)
#define HINTS_TEXT_LEN (160)
#define HINTS_CALLBACK_LEN (32)
#define HINTS_TIME_MS (5000)
#define HINTS_RADIUS (2.0)
#define HINTS_TRUCK_RADIUS (10.0)
#define HINTS_STYLE_DEFAULT (3)
#define HINTS_JOB_PLACES (12)

#define HINT_GATE_NONE (0)
#define HINT_GATE_NO_JOB (1)
#define HINT_GATE_NO_JOB_NO_MEMBER (2)
#define HINT_GATE_CALLBACK (3)

enum E_HINT
{
    Float:E_HINT_X,
    Float:E_HINT_Y,
    Float:E_HINT_Z,
    Float:E_HINT_RADIUS,
    E_HINT_TEXT[HINTS_TEXT_LEN],
    E_HINT_STYLE,
    bool:E_HINT_ON_FOOT,
    E_HINT_GATE_KIND,
    E_HINT_GATE_CALLBACK[HINTS_CALLBACK_LEN],
    E_HINT_ACTION[HINTS_CALLBACK_LEN]
}

static s_Hints[HINTS_MAX][E_HINT];
static s_HintCount;

static const Float:s_HintsJobPlaces[HINTS_JOB_PLACES][3] =
{
    {359.5408, 206.7693, 1008.3828},
    {347.7374, 193.7241, 1014.1875},
    {1215.1304, -11.8431, 1000.9219},
    {2166.3772, -1675.3829, 15.0859},
    {1109.3318, -1796.3042, 16.5938},
    {-1932.3859, 276.2117, 41.0391},
    {2226.1716, -1718.1792, 13.5165},
    {1366.4325, -1275.2096, 13.5469},
    {531.7930, -1292.4044, 17.2422},
    {766.0804, 14.5133, 1000.7004},
    {1154.2208, -1770.8203, 16.5992},
    {-77.7288, -1136.3896, 1.0781}
};

static const s_HintsJobPlaceJobs[HINTS_JOB_PLACES] =
{
    JOB_DETECTIVE,
    JOB_LAWYER,
    JOB_WHORE,
    JOB_DRUGS,
    JOB_CARJACKER,
    JOB_MECHANIC,
    JOB_BODYGUARD,
    JOB_ARMS,
    JOB_CARDEALER,
    JOB_BOXER,
    JOB_BUS,
    JOB_TRUCKER
};

static const s_HintsJobPlaceGates[HINTS_JOB_PLACES] =
{
    HINT_GATE_NO_JOB_NO_MEMBER,
    HINT_GATE_NO_JOB,
    HINT_GATE_NO_JOB_NO_MEMBER,
    HINT_GATE_NO_JOB_NO_MEMBER,
    HINT_GATE_NO_JOB,
    HINT_GATE_NO_JOB_NO_MEMBER,
    HINT_GATE_NO_JOB_NO_MEMBER,
    HINT_GATE_NO_JOB_NO_MEMBER,
    HINT_GATE_NO_JOB,
    HINT_GATE_NO_JOB_NO_MEMBER,
    HINT_GATE_NO_JOB_NO_MEMBER,
    HINT_GATE_NO_JOB_NO_MEMBER
};

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
static Hints_Add(Float:x,Float:y,Float:z,Float:radius,const text[],style,bool:onFoot,gateKind,const gate[],const action[])
{
    if (s_HintCount >= HINTS_MAX)
    {
        Log_Error("hints","hint table full, %s was not added",text);
        return -1;
    }

    new slot = s_HintCount++;
    s_Hints[slot][E_HINT_X] = x;
    s_Hints[slot][E_HINT_Y] = y;
    s_Hints[slot][E_HINT_Z] = z;
    s_Hints[slot][E_HINT_RADIUS] = radius;
    strcopy(s_Hints[slot][E_HINT_TEXT],text,HINTS_TEXT_LEN);
    s_Hints[slot][E_HINT_STYLE] = style;
    s_Hints[slot][E_HINT_ON_FOOT] = onFoot;
    s_Hints[slot][E_HINT_GATE_KIND] = gateKind;
    strcopy(s_Hints[slot][E_HINT_GATE_CALLBACK],gate,HINTS_CALLBACK_LEN);
    strcopy(s_Hints[slot][E_HINT_ACTION],action,HINTS_CALLBACK_LEN);
    return slot;
}

stock Hints_Register(Float:x,Float:y,Float:z,Float:radius,const text[],style = HINTS_STYLE_DEFAULT,bool:onFoot = false,const gate[] = "")
{
    return Hints_Add(x,y,z,radius,text,style,onFoot,gate[0] == EOS ? HINT_GATE_NONE : HINT_GATE_CALLBACK,gate,"");
}

stock Hints_RegisterAction(Float:x,Float:y,Float:z,Float:radius,const action[],bool:onFoot = false,const gate[] = "")
{
    return Hints_Add(x,y,z,radius,"",HINTS_STYLE_DEFAULT,onFoot,gate[0] == EOS ? HINT_GATE_NONE : HINT_GATE_CALLBACK,gate,action);
}

stock Hints_Show(playerid,const text[],style)
{
    GameTextForPlayer(playerid,text,HINTS_TIME_MS,style);
}

stock Hints_RegisterBuiltin()
{
    Hints_Add(1173.2563,-1323.3102,15.3943,HINTS_RADIUS,"~w~Type /healme to cure yourself",5,false,HINT_GATE_NONE,"","");
    Hints_Add(2029.5945,-1404.6426,17.2512,HINTS_RADIUS,"~w~Type /healme to cure yourself",5,false,HINT_GATE_NONE,"","");
    Hints_Add(-2162.2554,-2385.9541,30.6250,3.0,"~y~Welcome to the ~r~City Hall~n~~w~Type /enter to go in",5,false,HINT_GATE_NONE,"","");

    new text[HINTS_TEXT_LEN], jobName[16];

    for (new i = 0;i < HINTS_JOB_PLACES;i++)
    {
        Jobs_GetName(s_HintsJobPlaceJobs[i],jobName);
        format(text,sizeof(text),"~g~Welcome,~n~~y~you can become a ~r~%s~y~ here ~n~~w~Type /join if you wish to become one",jobName);
        Hints_Add(s_HintsJobPlaces[i][0],s_HintsJobPlaces[i][1],s_HintsJobPlaces[i][2],HINTS_RADIUS,text,HINTS_STYLE_DEFAULT,true,s_HintsJobPlaceGates[i],"","");
    }
}

static bool:Hints_GatePasses(playerid,slot)
{
    switch (s_Hints[slot][E_HINT_GATE_KIND])
    {
        case HINT_GATE_NO_JOB:
        {
            return Jobs_GetJob(playerid) <= 0;
        }

        case HINT_GATE_NO_JOB_NO_MEMBER:
        {
            return Jobs_GetJob(playerid) <= 0 && Factions_GetMember(playerid) <= 0;
        }

        case HINT_GATE_CALLBACK:
        {
            return CallLocalFunction(s_Hints[slot][E_HINT_GATE_CALLBACK],"d",playerid) != 0;
        }
    }

    return true;
}

stock bool:Hints_ShowFixed(playerid)
{
    for (new slot = 0;slot < s_HintCount;slot++)
    {
        if (!Property_IsNear(playerid,s_Hints[slot][E_HINT_RADIUS],s_Hints[slot][E_HINT_X],s_Hints[slot][E_HINT_Y],s_Hints[slot][E_HINT_Z]))
        {
            continue;
        }

        if (s_Hints[slot][E_HINT_ON_FOOT] && GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
        {
            continue;
        }

        if (!Hints_GatePasses(playerid,slot))
        {
            continue;
        }

        if (s_Hints[slot][E_HINT_ACTION][0] != EOS)
        {
            CallLocalFunction(s_Hints[slot][E_HINT_ACTION],"d",playerid);
        }
        else
        {
            Hints_Show(playerid,s_Hints[slot][E_HINT_TEXT],s_Hints[slot][E_HINT_STYLE]);
        }

        return true;
    }

    return false;
}
