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
#define TELEPORT_STEP (2.0)
#define TELEPORT_FLY_LONG (30.0)
#define TELEPORT_FLY_DIAGONAL (15.0)
#define TELEPORT_FLY_LIFT (5.0)
#define TELEPORT_CAR_OFFSET (4.0)
#define TELEPORT_PLAYER_OFFSET (2.0)
#define TELEPORT_HIGHEST_LAND (530.0)
#define TELEPORT_HIGHEST_FETCH (930.0)
#define TELEPORT_SKYDIVE_HEIGHT (1500.0)
#define TELEPORT_PARACHUTE (46)
#define TELEPORT_TEXT_MS (5000)

static const Float:s_TeleportFourDive[4][3] =
{
    {1536.0, -1360.0, 1350.0},
    {1536.0, -1345.0, 1350.0},
    {1552.0, -1345.0, 1350.0},
    {1552.0, -1360.0, 1350.0}
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
static Teleport_Place(playerid,Float:x,Float:y,Float:z,bool:resetSpeed)
{
    if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        SetVehiclePos(GetPlayerVehicleID(playerid),x,y,z);

        if (resetSpeed)
        {
            Speedo_ResetSample(playerid);
        }

        return;
    }

    SetPlayerPos(playerid,x,y,z);
}

static Teleport_Fixed(playerid,Float:x,Float:y,Float:z,interior,bool:resetSpeed,bool:keepAccount,const message[],bool:messageFirst)
{
    if (messageFirst)
    {
        Teleport_Place(playerid,x,y,z,resetSpeed);
        SendClientMessage(playerid,COLOR_GRAD1,message);
        SetPlayerInterior(playerid,interior);
        SetPlayerVirtualWorld(playerid,0);
    }
    else
    {
        Teleport_Place(playerid,x,y,z,resetSpeed);
        SetPlayerInterior(playerid,interior);
        SetPlayerVirtualWorld(playerid,0);
        SendClientMessage(playerid,COLOR_GRAD1,message);
    }

    if (!keepAccount)
    {
        Account_SetInterior(playerid,interior);
    }
}

static Teleport_Step(playerid,Float:deltaX,Float:deltaY,Float:deltaZ)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    SetPlayerPos(playerid,x + deltaX,y + deltaY,z + deltaZ);
}

static bool:Teleport_FindStaffTarget(playerid,const params[],const usage[],&targetid)
{
    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,usage);
        return false;
    }

    targetid = Staff_FindPlayer(token);

    if (!Staff_IsTarget(targetid))
    {
        new line[STAFF_LINE_LEN];
        format(line,sizeof(line),"   %s is not an active player.",token);
        SendClientMessage(playerid,COLOR_GRAD1,line);
        return false;
    }

    return true;
}

static Teleport_ReadNumber(const params[],&at,&value)
{
    new token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        return false;
    }

    value = strval(token);
    return true;
}

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
CMD<ADMIN_LEVEL_TRIAL>:dn(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Teleport_Step(playerid,0.0,0.0,-TELEPORT_STEP);
    return 1;
}

CMD<ADMIN_LEVEL_TRIAL>:up(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Teleport_Step(playerid,0.0,0.0,TELEPORT_STEP);
    return 1;
}

CMD<ADMIN_LEVEL_TRIAL>:lt(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Teleport_Step(playerid,0.0,TELEPORT_STEP,0.0);
    return 1;
}

CMD<ADMIN_LEVEL_TRIAL>:rt(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Teleport_Step(playerid,0.0,-TELEPORT_STEP,-TELEPORT_STEP);
    return 1;
}

CMD<ADMIN_LEVEL_TRIAL>:fly(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new Float:angle;
    GetPlayerFacingAngle(playerid,angle);

    if (angle >= 0.0 && angle <= 22.5)
    {
        Teleport_Step(playerid,0.0,TELEPORT_FLY_LONG,TELEPORT_FLY_LIFT);
    }

    if (angle >= 22.5 && angle <= 67.5)
    {
        Teleport_Step(playerid,-TELEPORT_FLY_DIAGONAL,TELEPORT_FLY_DIAGONAL,TELEPORT_FLY_LIFT);
    }

    if (angle >= 67.5 && angle <= 112.5)
    {
        Teleport_Step(playerid,-TELEPORT_FLY_LONG,0.0,TELEPORT_FLY_LIFT);
    }

    if (angle >= 112.5 && angle <= 157.5)
    {
        Teleport_Step(playerid,-TELEPORT_FLY_DIAGONAL,-TELEPORT_FLY_DIAGONAL,TELEPORT_FLY_LIFT);
    }

    if (angle >= 157.5 && angle <= 202.5)
    {
        Teleport_Step(playerid,0.0,-TELEPORT_FLY_LONG,TELEPORT_FLY_LIFT);
    }

    if (angle >= 202.5 && angle <= 247.5)
    {
        Teleport_Step(playerid,TELEPORT_FLY_DIAGONAL,-TELEPORT_FLY_DIAGONAL,TELEPORT_FLY_LIFT);
    }

    if (angle >= 247.5 && angle <= 292.5)
    {
        Teleport_Step(playerid,TELEPORT_FLY_LONG,0.0,TELEPORT_FLY_LIFT);
    }

    if (angle >= 292.5 && angle <= 332.5)
    {
        Teleport_Step(playerid,TELEPORT_FLY_DIAGONAL,TELEPORT_FLY_DIAGONAL,TELEPORT_FLY_LIFT);
    }

    return 1;
}

CMD:house(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Staff_HasLevel(playerid,ADMIN_LEVEL_DEVELOPER))
    {
        return 1;
    }

    new at = 0, house;

    if (!Teleport_ReadNumber(params,at,house))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /house [housenumber]");
        return 1;
    }

    if (!Houses_IsValid(house))
    {
        return 1;
    }

    Houses_Place(playerid,house);
    GameTextForPlayer(playerid,"~w~Teleporting",TELEPORT_TEXT_MS,1);
    return 1;
}

CMD:houseo(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Staff_HasLevel(playerid,ADMIN_LEVEL_DEVELOPER))
    {
        return 1;
    }

    new at = 0, house;

    if (!Teleport_ReadNumber(params,at,house))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /houseo [housenumber]");
        return 1;
    }

    if (!Houses_IsValid(house))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z;
    Houses_GetEntrance(house,x,y,z);
    SetPlayerVirtualWorld(playerid,0);
    SetPlayerPos(playerid,x,y,z);
    GameTextForPlayer(playerid,"~w~Teleporting",TELEPORT_TEXT_MS,1);
    return 1;
}

CMD:biz(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Staff_HasLevel(playerid,ADMIN_LEVEL_DEVELOPER))
    {
        return 1;
    }

    new at = 0, key;

    if (!Teleport_ReadNumber(params,at,key))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /biz [biznumber]");
        return 1;
    }

    if (key < 0 || key >= BUSINESS_COUNT || !Business_IsValid(key))
    {
        return 1;
    }

    Doors_Place(playerid,Business_GetDoor(key));
    GameTextForPlayer(playerid,"~w~Teleporting",TELEPORT_TEXT_MS,1);
    return 1;
}

CMD:sbiz(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Staff_HasLevel(playerid,ADMIN_LEVEL_DEVELOPER))
    {
        return 1;
    }

    new at = 0, index;

    if (!Teleport_ReadNumber(params,at,index))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /sbiz [biznumber]");
        return 1;
    }

    if (index < 0 || index >= BUSINESS_SPECIAL_COUNT)
    {
        return 1;
    }

    new key = Business_MakeSpecialKey(index);

    if (!Business_IsValid(key))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z;
    Business_GetEntrance(key,x,y,z);
    SetPlayerInterior(playerid,Business_GetInterior(key));
    SetPlayerVirtualWorld(playerid,0);
    SetPlayerPos(playerid,x,y,z);
    GameTextForPlayer(playerid,"~w~Teleporting",TELEPORT_TEXT_MS,1);
    return 1;
}

CMD<ADMIN_LEVEL_TRIAL>:setint(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, interior;

    if (!Teleport_ReadNumber(params,at,interior))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /setint [interiorid]");
        return 1;
    }

    new line[STAFF_LINE_LEN];
    SetPlayerInterior(playerid,interior);
    Account_SetInterior(playerid,interior);
    format(line,sizeof(line),"   interiorid %d.",interior);
    SendClientMessage(playerid,COLOR_GRAD1,line);
    return 1;
}

CMD<ADMIN_LEVEL_MOD>:skydive(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    GivePlayerWeapon(playerid,WEAPON:TELEPORT_PARACHUTE,0);
    SetPlayerPos(playerid,x,y,z + TELEPORT_SKYDIVE_HEIGHT);
    SendClientMessage(playerid,COLOR_WHITE,"GO!! GO!! GO!!");
    return 1;
}

CMD<ADMIN_LEVEL_DEVELOPER>:fourdive(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, jumpers[4];

    if (!Teleport_ReadNumber(params,at,jumpers[0]))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /fourdive [playerid1] [playerid2] [playerid3] [playerid4]");
        return 1;
    }

    for (new i = 1;i < 4;i++)
    {
        Teleport_ReadNumber(params,at,jumpers[i]);
    }

    for (new i = 0;i < 4;i++)
    {
        new targetid = jumpers[i];

        if (!Util_IsValidPlayer(targetid) || (i > 0 && targetid <= 0))
        {
            continue;
        }

        GivePlayerWeapon(targetid,WEAPON:TELEPORT_PARACHUTE,0);
        SetPlayerPos(targetid,s_TeleportFourDive[i][0],s_TeleportFourDive[i][1],s_TeleportFourDive[i][2]);
        SetPlayerInterior(targetid,0);
        SetPlayerVirtualWorld(targetid,0);
        Account_SetInterior(targetid,0);
        SendClientMessage(targetid,i == 0 ? COLOR_WHITE : COLOR_RED,"GO!! GO!! GO!!");
    }

    return 1;
}

CMD<ADMIN_LEVEL_ADMIN>:gotols(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Teleport_Fixed(playerid,1529.6,-1691.2,13.3,0,true,false,"   You have been teleported !",true);
    return 1;
}

CMD<ADMIN_LEVEL_ADMIN>:gotolv(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Teleport_Fixed(playerid,1699.2,1435.1,10.7,0,true,false,"   You have been teleported",true);
    return 1;
}

CMD<ADMIN_LEVEL_ADMIN>:gotosf(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Teleport_Fixed(playerid,-1417.0,-295.8,14.1,0,true,false,"   You have been teleported",true);
    return 1;
}

CMD<ADMIN_LEVEL_ADMIN>:entercar(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, vehicleid;

    if (!Teleport_ReadNumber(params,at,vehicleid))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /entercar [carid]");
        return 1;
    }

    if (Util_IsValidVehicle(vehicleid))
    {
        PutPlayerInVehicle(playerid,vehicleid,1);
    }

    SendClientMessage(playerid,COLOR_GRAD1,"   You have been teleported");
    return 1;
}

CMD<ADMIN_LEVEL_ADMIN>:gotocar(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, vehicleid;

    if (!Teleport_ReadNumber(params,at,vehicleid))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /gotocar [carid]");
        return 1;
    }

    if (!Util_IsValidVehicle(vehicleid))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z;
    GetVehiclePos(vehicleid,x,y,z);
    Teleport_Place(playerid,x,y,z,true);
    SendClientMessage(playerid,COLOR_GRAD1,"   You have been teleported");
    SetPlayerInterior(playerid,0);
    SetPlayerVirtualWorld(playerid,0);
    return 1;
}

CMD<ADMIN_LEVEL_ADMIN>:mark(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    Staff_SetMark(playerid,x,y,z);
    SendClientMessage(playerid,COLOR_GRAD1,"   teleporter destination set");
    return 1;
}

CMD<ADMIN_LEVEL_ADMIN>:gotomark(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new Float:x, Float:y, Float:z;
    Staff_GetMark(playerid,x,y,z);
    Teleport_Place(playerid,x,y,z,true);
    SendClientMessage(playerid,COLOR_GRAD1,"   You have been teleported");
    SetPlayerInterior(playerid,0);
    SetPlayerVirtualWorld(playerid,0);
    return 1;
}

CMD<ADMIN_LEVEL_ADMIN>:gotoin(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Teleport_Fixed(playerid,1416.107000,0.268620,1000.926000,1,false,true,"   You have been teleported",true);
    return 1;
}

CMD<ADMIN_LEVEL_ADMIN>:gotostad(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Teleport_Fixed(playerid,-1435.75,-652.664,1054.94,4,false,true,"   You have been teleported",false);
    return 1;
}

CMD<ADMIN_LEVEL_ADMIN>:gotojet(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Teleport_Fixed(playerid,1.71875,30.4062,1200.34,1,false,true,"   You have been teleported",false);
    return 1;
}

CMD<ADMIN_LEVEL_TRIAL>:goto(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;

    if (!Teleport_FindStaffTarget(playerid,params,"USAGE: /goto [playerid/PartOfName]",targetid))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z, targetInterior = Account_GetInterior(targetid);

    if (Staff_IsSpectating(playerid))
    {
        Staff_SetSpectateMode(playerid,STAFF_SPECTATE_RELEASE);
    }

    GetPlayerPos(targetid,x,y,z);

    SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(targetid));

    if (targetInterior > 0)
    {
        SetPlayerInterior(playerid,targetInterior);
        Account_SetInterior(playerid,targetInterior);
        Account_SetLocal(playerid,Account_GetLocal(targetid));
    }

    if (Account_GetInterior(playerid) == 0)
    {
        SetPlayerInterior(playerid,0);
    }

    if (z > TELEPORT_HIGHEST_LAND && targetInterior == 0)
    {
        SetPlayerInterior(playerid,1);
        Account_SetInterior(playerid,1);
    }

    if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        SetVehiclePos(GetPlayerVehicleID(playerid),x,y + TELEPORT_CAR_OFFSET,z);
        Speedo_ResetSample(playerid);
    }
    else
    {
        SetPlayerPos(playerid,x,y + TELEPORT_PLAYER_OFFSET,z);
    }

    SendClientMessage(playerid,COLOR_GRAD1,"   You have been teleported");
    return 1;
}

CMD<ADMIN_LEVEL_ADMIN>:gethere(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;

    if (!Teleport_FindStaffTarget(playerid,params,"USAGE: /gethere [playerid/PartOfName]",targetid))
    {
        return 1;
    }

    if (Account_GetAdminLevel(targetid) > ADMIN_LEVEL_DEVELOPER)
    {
        SendClientMessage(playerid,COLOR_GRAD1,"Ask the admin to goto you.");
        return 1;
    }

    new Float:x, Float:y, Float:z, interior = Account_GetInterior(playerid);
    GetPlayerPos(playerid,x,y,z);

    SetPlayerVirtualWorld(targetid,GetPlayerVirtualWorld(playerid));

    if (interior > 0)
    {
        SetPlayerInterior(targetid,interior);
        Account_SetInterior(targetid,interior);
        Account_SetLocal(targetid,Account_GetLocal(playerid));
    }

    if (interior == 0)
    {
        SetPlayerInterior(targetid,0);
    }

    if (z > TELEPORT_HIGHEST_FETCH && interior == 0)
    {
        SetPlayerInterior(targetid,1);
        Account_SetInterior(targetid,1);
    }

    if (GetPlayerState(targetid) == PLAYER_STATE_DRIVER)
    {
        Speedo_ResetSample(targetid);
        SetVehiclePos(GetPlayerVehicleID(targetid),x,y + TELEPORT_CAR_OFFSET,z);
    }
    else
    {
        SetPlayerPos(targetid,x,y + TELEPORT_PLAYER_OFFSET,z);
    }

    SendClientMessage(targetid,COLOR_GRAD1,"   You have been teleported");
    return 1;
}

CMD<ADMIN_LEVEL_ADMIN>:getcar(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, vehicleid;

    if (!Teleport_ReadNumber(params,at,vehicleid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /getcar [carid]");
        return 1;
    }

    if (!Util_IsValidVehicle(vehicleid))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    SetVehiclePos(vehicleid,x,y + TELEPORT_CAR_OFFSET,z);
    return 1;
}
