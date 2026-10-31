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
#define SPAWN_PEDS_COUNT (217)
#define SPAWN_CLASS_SOUND (1187)
#define SPAWN_CLASS_TEXT_MS (3500)
#define SPAWN_CLASS_TEXT_STYLE (6)
#define SPAWN_LEADER_TEAM (11)
#define SPAWN_CIVILIAN_TEAM (3)
#define SPAWN_CLASS_LEADER_FIRST (1)
#define SPAWN_CLASS_LEADER_LAST (11)
#define SPAWN_CLASS_X (1958.3783)
#define SPAWN_CLASS_Y (1343.1572)
#define SPAWN_CLASS_Z (1100.3746)
#define SPAWN_CLASS_ANGLE (269.1425)
#define SPAWN_RANDOM_ANGLE (270.0)
#define SPAWN_RANDOM_INTERIOR (15)
#define SPAWN_KICK_MESSAGE "** This server requires a Login BEFORE spawn (Kicked) **"

enum
{
    SPAWN_PRIORITY_DEFAULT = 0,
    SPAWN_PRIORITY_FAMILY = 10,
    SPAWN_PRIORITY_MEDIC_TEAM = 20,
    SPAWN_PRIORITY_INSTRUCTOR = 30,
    SPAWN_PRIORITY_TAXI = 40,
    SPAWN_PRIORITY_NEWS = 50,
    SPAWN_PRIORITY_HITMAN = 60,
    SPAWN_PRIORITY_YAKUZA = 70,
    SPAWN_PRIORITY_LCN = 80,
    SPAWN_PRIORITY_FIREMEN = 90,
    SPAWN_PRIORITY_NATIONAL_GUARD = 100,
    SPAWN_PRIORITY_POLICE = 110,
    SPAWN_PRIORITY_MAYOR = 120,
    SPAWN_PRIORITY_HOUSE = 130,
    SPAWN_PRIORITY_CAMERA = 135,
    SPAWN_PRIORITY_PRISON = 140,
    SPAWN_PRIORITY_JAIL = 150,
    SPAWN_PRIORITY_PAINTBALL = 160
}

static const s_SpawnPeds[SPAWN_PEDS_COUNT] =
{
    264, 288, 286, 287, 228, 113, 120, 147, 294, 227, 61, 171,
    247, 248, 100, 256, 263, 262, 261, 260, 259, 258, 257, 256,
    255, 253, 252, 251, 249, 246, 245, 244, 243, 242, 241, 240,
    239, 238, 237, 236, 235, 234, 233, 232, 231, 230, 229, 226,
    225, 173, 174, 175, 224, 223, 222, 221, 220, 219, 218, 217,
    216, 215, 214, 213, 212, 211, 210, 209, 207, 206, 205, 204,
    203, 202, 201, 200, 199, 198, 197, 196, 195, 194, 193, 192,
    191, 190, 189, 185, 184, 183, 182, 181, 180, 179, 178, 176,
    172, 170, 168, 167, 162, 161, 160, 159, 158, 157, 156, 155,
    154, 153, 152, 151, 146, 145, 144, 143, 142, 141, 140, 139,
    138, 137, 136, 135, 134, 133, 132, 131, 130, 129, 128, 254,
    99, 97, 96, 95, 94, 92, 90, 89, 88, 87, 85, 84,
    83, 82, 81, 80, 79, 78, 77, 76, 75, 73, 72, 69,
    68, 67, 66, 64, 63, 62, 58, 57, 56, 55, 54, 53,
    52, 51, 50, 49, 45, 44, 43, 41, 39, 38, 37, 36,
    35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24,
    23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12,
    11, 10, 1, 2, 290, 291, 292, 293, 187, 296, 297, 298,
    299
};

static const Float:s_SpawnOriginPoints[3][4] =
{
    {-2721.2612, -317.8447, 7.8438, 46.8583},
    {477.8121, -1499.7649, 20.5001, 262.9963},
    {-2155.4368, 635.8173, 52.3672, 272.3543}
};

static const Float:s_SpawnRandomPoints[1][3] =
{
    {2223.8, -1147.1, 1025.7}
};

static s_SpawnClassModel[MAX_PLAYERS];
static s_SpawnClassTeam[MAX_PLAYERS];
static bool:s_SpawnHasPoint[MAX_PLAYERS];
static s_SpawnPointPriority[MAX_PLAYERS];
static Float:s_SpawnPointX[MAX_PLAYERS];
static Float:s_SpawnPointY[MAX_PLAYERS];
static Float:s_SpawnPointZ[MAX_PLAYERS];
static Float:s_SpawnPointAngle[MAX_PLAYERS];
static s_SpawnPointInterior[MAX_PLAYERS];

forward Spawn_OnChoose(playerid);

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
stock Spawn_GetPedModel(classid)
{
    if (classid < 0 || classid >= SPAWN_PEDS_COUNT)
    {
        return s_SpawnPeds[0];
    }

    return s_SpawnPeds[classid];
}

stock Spawn_ResetPlayer(playerid)
{
    s_SpawnClassModel[playerid] = 0;
    s_SpawnClassTeam[playerid] = SPAWN_CIVILIAN_TEAM;
    Spawn_ClearPoint(playerid);
}

stock Spawn_GetClassTeam(playerid)
{
    return s_SpawnClassTeam[playerid];
}

stock Spawn_SetClassChoice(playerid,model,team)
{
    s_SpawnClassModel[playerid] = model;
    s_SpawnClassTeam[playerid] = team;

    if (Player_IsReady(playerid))
    {
        Account_SetModel(playerid,model);
        Account_SetTeam(playerid,team);
    }
}

stock Spawn_ClearPoint(playerid)
{
    s_SpawnHasPoint[playerid] = false;
    s_SpawnPointPriority[playerid] = SPAWN_PRIORITY_DEFAULT;
}

stock bool:Spawn_SetPoint(playerid,Float:x,Float:y,Float:z,Float:angle,interior,priority)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return false;
    }

    if (s_SpawnHasPoint[playerid] && priority <= s_SpawnPointPriority[playerid])
    {
        return false;
    }

    s_SpawnHasPoint[playerid] = true;
    s_SpawnPointPriority[playerid] = priority;
    s_SpawnPointX[playerid] = x;
    s_SpawnPointY[playerid] = y;
    s_SpawnPointZ[playerid] = z;
    s_SpawnPointAngle[playerid] = angle;
    s_SpawnPointInterior[playerid] = interior;
    return true;
}

stock bool:Spawn_HasPoint(playerid)
{
    return Util_IsValidPlayer(playerid) && s_SpawnHasPoint[playerid];
}

stock Spawn_GetPointPriority(playerid)
{
    if (!Spawn_HasPoint(playerid))
    {
        return -1;
    }

    return s_SpawnPointPriority[playerid];
}

stock Spawn_GetPoint(playerid,&Float:x,&Float:y,&Float:z,&Float:angle,&interior)
{
    x = s_SpawnPointX[playerid];
    y = s_SpawnPointY[playerid];
    z = s_SpawnPointZ[playerid];
    angle = s_SpawnPointAngle[playerid];
    interior = s_SpawnPointInterior[playerid];
}

stock Spawn_GetDefaultPoint(origin,&Float:x,&Float:y,&Float:z,&Float:angle,&interior)
{
    if (origin >= 1 && origin <= 3)
    {
        x = s_SpawnOriginPoints[origin - 1][0];
        y = s_SpawnOriginPoints[origin - 1][1];
        z = s_SpawnOriginPoints[origin - 1][2];
        angle = s_SpawnOriginPoints[origin - 1][3];
        interior = 0;
        return;
    }

    new pick = random(sizeof(s_SpawnRandomPoints));
    x = s_SpawnRandomPoints[pick][0];
    y = s_SpawnRandomPoints[pick][1];
    z = s_SpawnRandomPoints[pick][2];
    angle = SPAWN_RANDOM_ANGLE;
    interior = SPAWN_RANDOM_INTERIOR;
}
