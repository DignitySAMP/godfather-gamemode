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
#define WORLD_ANNOUNCE_MS (5000)
#define WORLD_ANNOUNCE_STYLE (6)
#define WORLD_CNNN_BLOCKED (2)
#define WORLD_VEHICLE_MIN (400)
#define WORLD_VEHICLE_MAX (611)
#define WORLD_COLOUR_MAX (126)
#define WORLD_WEATHER_MAX (45)
#define WORLD_VEHICLE_RESPAWN (60000)
#define WORLD_FIX_HEALTH (1000.0)
#define WORLD_EXIT_MS (4000)
#define WORLD_EXIT_TEXT_STYLE (5)
#define WORLD_EXIT_CAMERA_X (1460.0)
#define WORLD_EXIT_CAMERA_Y (-1324.0)
#define WORLD_EXIT_CAMERA_Z (287.2)
#define WORLD_EXIT_LOOK_X (1374.5)
#define WORLD_EXIT_LOOK_Y (-1291.1)
#define WORLD_EXIT_LOOK_Z (239.0)

forward World_ExitTimer();

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
static World_GameTextAll(const text[],style)
{
    foreach (new i : Player)
    {
        if (!IsPlayerNPC(i))
        {
            GameTextForPlayer(i,text,WORLD_ANNOUNCE_MS,style);
        }
    }
}

stock World_BeginExit()
{
    foreach (new i : Player)
    {
        if (IsPlayerNPC(i))
        {
            continue;
        }

        DisablePlayerCheckpoint(i);
        GameTextForPlayer(i,"Traveling...",WORLD_EXIT_MS,WORLD_EXIT_TEXT_STYLE);
        SetPlayerCameraPos(i,WORLD_EXIT_CAMERA_X,WORLD_EXIT_CAMERA_Y,WORLD_EXIT_CAMERA_Z);
        SetPlayerCameraLookAt(i,WORLD_EXIT_LOOK_X,WORLD_EXIT_LOOK_Y,WORLD_EXIT_LOOK_Z);
        Account_Logout(i);
    }

    SetTimer("World_ExitTimer",WORLD_EXIT_MS,false);
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
public World_ExitTimer()
{
    GameModeExit();
    return 1;
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
CMD<ADMIN_LEVEL_TRIAL>:cnn(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new result[STAFF_REASON_LEN];

    if (Util_ReadRest(params,0,result) == 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /cnn [cnn textformat ~n~=Newline ~r~=Red ~g~=Green ~b~=Blue ~w~=White ~y~=Yellow]");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], line[STAFF_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"~b~%s: ~w~%s",name,result);
    World_GameTextAll(line,WORLD_ANNOUNCE_STYLE);
    return 1;
}

CMD<ADMIN_LEVEL_DEVELOPER>:cnnn(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /cnnn <type> ");
        return 1;
    }

    new style = strval(token);

    if (style == WORLD_CNNN_BLOCKED)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"You can not select 2");
        return 1;
    }

    new result[STAFF_REASON_LEN];

    if (Util_ReadRest(params,at,result) == 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /cnnn <type> [cnnc textformat ~n~=Newline ~r~=Red ~g~=Green ~b~=Blue ~w~=White ~y~=Yellow]");
        return 1;
    }

    new line[STAFF_LINE_LEN];
    format(line,sizeof(line),"~w~%s",result);
    World_GameTextAll(line,style);
    return 1;
}

CMD<ADMIN_LEVEL_DEVELOPER>:tod(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /tod [timeofday] (0-23)");
        return 1;
    }

    new hour = strval(token), line[STAFF_LINE_LEN];

    if (hour < 0 || hour > 23)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /tod [timeofday] (0-23)");
        return 1;
    }

    SetWorldTime(hour);
    format(line,sizeof(line),"   Time set to %d Hours.",hour);
    Staff_Say(COLOR_GRAD1,line);
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:fuelcars(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Fuel_FillAll();
    SendClientMessage(playerid,COLOR_GREY,"   All cars filled with Fuel ! ");
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:veh(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /veh [carid] [color1] [color2]");
        return 1;
    }

    new model = strval(token);

    if (model < WORLD_VEHICLE_MIN || model > WORLD_VEHICLE_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Vehicle Number can't be below 400 or above 611 !");
        return 1;
    }

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /veh [carid] [color1] [color2]");
        return 1;
    }

    new colour1 = strval(token);

    if (colour1 < 0 || colour1 > WORLD_COLOUR_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Color Number can't be below 0 or above 126 !");
        return 1;
    }

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /veh [carid] [color1] [color2]");
        return 1;
    }

    new colour2 = strval(token);

    if (colour2 < 0 || colour2 > WORLD_COLOUR_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Color Number can't be below 0 or above 126 !");
        return 1;
    }

    if (Staff_CreatedCarsFull())
    {
        return 1;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);

    new vehicleid = CreateVehicle(model,x,y,z,0.0,colour1,colour2,WORLD_VEHICLE_RESPAWN);

    if (vehicleid == INVALID_VEHICLE_ID)
    {
        return 1;
    }

    Staff_TrackCreatedCar(vehicleid);

    new line[STAFF_LINE_LEN];
    format(line,sizeof(line),"   Vehicle %d spawned.",vehicleid);
    SendClientMessage(playerid,COLOR_GREY,line);
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:fixveh(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (IsPlayerInAnyVehicle(playerid))
    {
        SetVehicleHealth(GetPlayerVehicleID(playerid),WORLD_FIX_HEALTH);
        SendClientMessage(playerid,COLOR_GREY,"   Vehicle Fixed !");
    }

    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:destroycars(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Staff_DestroyCreatedCars();
    SendClientMessage(playerid,COLOR_GREY,"   Created Vehicles destroyed !");
    return 1;
}

CMD<ADMIN_LEVEL_DEVELOPER>:weather(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /weather [weatherid]");
        return 1;
    }

    new weather = strval(token);

    if (weather < 0 || weather > WORLD_WEATHER_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Weather ID can't be below 0 or above 45 !");
        return 1;
    }

    SetPlayerWeather(playerid,weather);
    SendClientMessage(playerid,COLOR_GREY,"   Weather Set !");
    return 1;
}

CMD<ADMIN_LEVEL_DEVELOPER>:weatherall(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /weatherall [weatherid]");
        return 1;
    }

    new weather = strval(token);

    if (weather < 0 || weather > WORLD_WEATHER_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Weather ID can't be below 0 or above 45 !");
        return 1;
    }

    SetWeather(weather);
    SendClientMessage(playerid,COLOR_GREY,"   Weather Set to everyone !");
    return 1;
}

CMD<ADMIN_LEVEL_ADMIN>:endround(cmdid, playerid, params[])
{
    #pragma unused cmdid, playerid, params

    World_BeginExit();
    return 1;
}

CMD<ADMIN_LEVEL_DEVELOPER>:gmx(cmdid, playerid, params[])
{
    #pragma unused cmdid, playerid, params

    GameModeExit();
    return 1;
}
