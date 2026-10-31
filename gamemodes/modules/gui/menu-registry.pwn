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
#define MENUREG_MAX_ITEMS (16)
#define MENUREG_LABEL_MAX (32)
#define MENUREG_CB_MAX (32)
#define MENUREG_CANCEL_VALUE (-777)

#define MENUREG_MENU_PLAYER (0)
#define MENUREG_MENU_VEHICLE (1)

#define MENUREG_FOOT_KEY_A (KEY_WALK)
#define MENUREG_FOOT_KEY_B (KEY_SPRINT)
#define MENUREG_VEH_HOLD_KEY_A (KEY_SUBMISSION)
#define MENUREG_VEH_HOLD_KEY_B (KEY_YES)
#define MENUREG_VEH_HOLD_MS (1500)
#define MENUREG_VEH_MAX_KMH (5.0)

#define MENUREG_MAX_GROUPS (8)
#define MENUREG_GROUP_BASE (-2000)

enum e_MENUREG_ITEM
{
    E_MENUREG_LABEL[MENUREG_LABEL_MAX],
    E_MENUREG_CB[MENUREG_CB_MAX],
    bool:E_MENUREG_PASSENGER,
    E_MENUREG_VISIBLE[MENUREG_CB_MAX],
    E_MENUREG_ORDER,
    E_MENUREG_GROUP[MENUREG_LABEL_MAX],
}

static List:s_MenuRegPlayer;
static List:s_MenuRegVehicle;
static s_MenuRegContext[MAX_PLAYERS] = {-1,...};
static bool:s_MenuRegInGroup[MAX_PLAYERS];
static s_MenuRegLastGroup[MAX_PLAYERS] = {-1,...};
static s_MenuRegHoldTimer[MAX_PLAYERS] = {-1,...};
static s_MenuRegBlocks[MAX_PLAYERS];
static s_MenuRegFootProvider[MENUREG_CB_MAX];
static s_MenuRegCancelLabel[MAX_PLAYERS][MENUREG_LABEL_MAX];
static s_MenuRegCancelCallback[MAX_PLAYERS][MENUREG_CB_MAX];
static s_MenuRegGroupNames[MAX_PLAYERS][MENUREG_MAX_GROUPS][MENUREG_LABEL_MAX];

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

static bool:MenuReg_IsItemVisible(playerid,const item[e_MENUREG_ITEM])
{
    if (item[E_MENUREG_VISIBLE][0] == EOS)
    {
        return true;
    }

    return !!pawn_call_public(item[E_MENUREG_VISIBLE],"d",playerid);
}

stock Menu_ClearCancelAction(playerid)
{
    s_MenuRegCancelLabel[playerid][0] = EOS;
    s_MenuRegCancelCallback[playerid][0] = EOS;
}

stock Menu_PushBlock(playerid)
{
    s_MenuRegBlocks[playerid]++;
}

stock Menu_PopBlock(playerid)
{
    if (s_MenuRegBlocks[playerid] > 0)
    {
        s_MenuRegBlocks[playerid]--;
    }

}

static MenuReg_Open(playerid,menuType)
{
    if (s_MenuRegBlocks[playerid] > 0)
    {
        return;
    }

    new bool:isPassenger = GetPlayerState(playerid) == PLAYER_STATE_PASSENGER;

    Menubox_Clear(playerid);

    new List:registry = (menuType == MENUREG_MENU_PLAYER) ? s_MenuRegPlayer : s_MenuRegVehicle;

    new listed = 0;

    if (menuType == MENUREG_MENU_PLAYER && s_MenuRegCancelLabel[playerid][0] != EOS)
    {
        Menubox_AddItem(playerid,s_MenuRegCancelLabel[playerid],MENUREG_CANCEL_VALUE);
        listed++;
    }

    if (registry != List:0)
    {
        new item[e_MENUREG_ITEM], count = list_size(registry);
        new entryOrder[MENUREG_MAX_ITEMS * 2], entryValue[MENUREG_MAX_ITEMS * 2], entryLabel[MENUREG_MAX_ITEMS * 2][MENUREG_LABEL_MAX], entries = 0;
        new groupCount = 0;

        for (new i = 0;i < count;i++)
        {
            list_get_arr(registry,i,item);

            if (menuType == MENUREG_MENU_VEHICLE && isPassenger && !item[E_MENUREG_PASSENGER])
            {
                continue;
            }

            if (!MenuReg_IsItemVisible(playerid,item))
            {
                continue;
            }

            if (entries >= sizeof(entryOrder))
            {
                break;
            }

            if (menuType == MENUREG_MENU_PLAYER && item[E_MENUREG_GROUP][0] != EOS)
            {
                new slot = -1;

                for (new g = 0;g < groupCount;g++)
                {
                    if (strcmp(s_MenuRegGroupNames[playerid][g],item[E_MENUREG_GROUP],true) == 0)
                    {
                        slot = g;
                        break;
                    }
                }

                if (slot != -1)
                {
                    continue;
                }

                if (groupCount >= MENUREG_MAX_GROUPS)
                {
                    continue;
                }

                slot = groupCount++;
                format(s_MenuRegGroupNames[playerid][slot],MENUREG_LABEL_MAX,"%s",item[E_MENUREG_GROUP]);

                entryOrder[entries] = item[E_MENUREG_ORDER];
                entryValue[entries] = MENUREG_GROUP_BASE - slot;
                format(entryLabel[entries],MENUREG_LABEL_MAX,"%s",item[E_MENUREG_GROUP]);
                entries++;
                continue;
            }

            entryOrder[entries] = item[E_MENUREG_ORDER];
            entryValue[entries] = i;
            format(entryLabel[entries],MENUREG_LABEL_MAX,"%s",item[E_MENUREG_LABEL]);
            entries++;
        }

        for (new a = 1;a < entries;a++)
        {
            for (new b = a;b > 0 && entryOrder[b] < entryOrder[b - 1];b--)
            {
                new swapOrder = entryOrder[b], swapValue = entryValue[b], swapLabel[MENUREG_LABEL_MAX];

                strcopy(swapLabel,entryLabel[b]);
                entryOrder[b] = entryOrder[b - 1];
                entryValue[b] = entryValue[b - 1];
                strcopy(entryLabel[b],entryLabel[b - 1]);
                entryOrder[b - 1] = swapOrder;
                entryValue[b - 1] = swapValue;
                strcopy(entryLabel[b - 1],swapLabel);
            }
        }

        for (new e = 0;e < entries;e++)
        {
            Menubox_AddItem(playerid,entryLabel[e],entryValue[e]);
            listed++;
        }
    }

    if (listed == 0)
    {
        return;
    }

    s_MenuRegContext[playerid] = menuType;
    s_MenuRegInGroup[playerid] = false;

    if (menuType == MENUREG_MENU_PLAYER)
    {
        s_MenuRegLastGroup[playerid] = -1;
        Menubox_Show(playerid,"Menu","MenuReg_OnPick");
    }
    else
    {
        Menubox_Show(playerid,"Vehicle","MenuReg_OnPick");
    }
}

static MenuReg_CancelHold(playerid)
{
    if (s_MenuRegHoldTimer[playerid] != -1)
    {
        KillTimer(s_MenuRegHoldTimer[playerid]);
        s_MenuRegHoldTimer[playerid] = -1;
    }
}

static MenuReg_OpenGroup(playerid,slot)
{
    if (slot < 0 || slot >= MENUREG_MAX_GROUPS || s_MenuRegGroupNames[playerid][slot][0] == EOS || s_MenuRegPlayer == List:0)
    {
        return;
    }

    Menubox_Clear(playerid);

    new item[e_MENUREG_ITEM], count = list_size(s_MenuRegPlayer);
    new entryOrder[MENUREG_MAX_ITEMS], entryValue[MENUREG_MAX_ITEMS], entries = 0;

    for (new i = 0;i < count;i++)
    {
        list_get_arr(s_MenuRegPlayer,i,item);

        if (strcmp(item[E_MENUREG_GROUP],s_MenuRegGroupNames[playerid][slot],true) != 0)
        {
            continue;
        }

        if (!MenuReg_IsItemVisible(playerid,item) || entries >= sizeof(entryOrder))
        {
            continue;
        }

        entryOrder[entries] = item[E_MENUREG_ORDER];
        entryValue[entries] = i;
        entries++;
    }

    for (new a = 1;a < entries;a++)
    {
        for (new b = a;b > 0 && entryOrder[b] < entryOrder[b - 1];b--)
        {
            new swapOrder = entryOrder[b], swapValue = entryValue[b];

            entryOrder[b] = entryOrder[b - 1];
            entryValue[b] = entryValue[b - 1];
            entryOrder[b - 1] = swapOrder;
            entryValue[b - 1] = swapValue;
        }
    }

    if (entries == 0)
    {
        return;
    }

    for (new e = 0;e < entries;e++)
    {
        list_get_arr(s_MenuRegPlayer,entryValue[e],item);
        Menubox_AddItem(playerid,item[E_MENUREG_LABEL],entryValue[e]);
    }

    s_MenuRegContext[playerid] = MENUREG_MENU_PLAYER;
    s_MenuRegInGroup[playerid] = true;
    s_MenuRegLastGroup[playerid] = slot;
    Menubox_Show(playerid,s_MenuRegGroupNames[playerid][slot],"MenuReg_OnPick");
}

static MenuReg_HandleKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if (IsPlayerNPC(playerid) || Menubox_IsOpen(playerid) || GetPlayerState(playerid) == PLAYER_STATE_WASTED)
    {
        MenuReg_CancelHold(playerid);
        return;
    }

    if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        if (Keys_IsChord(newkeys,oldkeys,MENUREG_VEH_HOLD_KEY_A,MENUREG_VEH_HOLD_KEY_B))
        {
            MenuReg_CancelHold(playerid);
            s_MenuRegHoldTimer[playerid] = SetTimerEx("MenuReg_HoldCheck",MENUREG_VEH_HOLD_MS,false,"d",playerid);
        }
        else if (!(newkeys & MENUREG_VEH_HOLD_KEY_A) || !(newkeys & MENUREG_VEH_HOLD_KEY_B))
        {
            MenuReg_CancelHold(playerid);
        }
    }
    else
    {
        MenuReg_CancelHold(playerid);

        if (Keys_IsChord(newkeys,oldkeys,MENUREG_FOOT_KEY_A,MENUREG_FOOT_KEY_B))
        {
            if (s_MenuRegBlocks[playerid] == 0 && s_MenuRegFootProvider[0] != EOS && pawn_call_public(s_MenuRegFootProvider,"d",playerid) == 1)
            {
                return;
            }

            MenuReg_Open(playerid,MENUREG_MENU_PLAYER);
        }
    }
}

stock MenuReg_Init()
{
    Keys_RegisterChord(MENUREG_FOOT_KEY_A,MENUREG_FOOT_KEY_B,KEYS_PRIO_MENU,"MenuReg_ChordContext");
    Keys_RegisterChord(MENUREG_VEH_HOLD_KEY_A,MENUREG_VEH_HOLD_KEY_B,KEYS_PRIO_MENU,"MenuReg_VehHoldContext");
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
forward MenuReg_OnPick(playerid,response,listitem,const name[],value);

public MenuReg_OnPick(playerid,response,listitem,const name[],value)
{
#pragma unused listitem, name

    new menuType = s_MenuRegContext[playerid];
    new bool:wasGroup = s_MenuRegInGroup[playerid];

    s_MenuRegContext[playerid] = -1;
    s_MenuRegInGroup[playerid] = false;

    if (!response || menuType == -1)
    {
        if (!response && wasGroup && menuType == MENUREG_MENU_PLAYER)
        {
            MenuReg_Open(playerid,MENUREG_MENU_PLAYER);
        }

        return true;
    }

    if (value == MENUREG_CANCEL_VALUE)
    {
        if (s_MenuRegCancelCallback[playerid][0] != EOS)
        {
            pawn_call_public(s_MenuRegCancelCallback[playerid],"ds",playerid,"");
        }

        return true;
    }

    if (menuType == MENUREG_MENU_PLAYER && value <= MENUREG_GROUP_BASE)
    {
        MenuReg_OpenGroup(playerid,MENUREG_GROUP_BASE - value);
        return true;
    }

    new List:registry = (menuType == MENUREG_MENU_PLAYER) ? s_MenuRegPlayer : s_MenuRegVehicle;

    if (registry != List:0 && 0 <= value < list_size(registry))
    {
        new item[e_MENUREG_ITEM];
        list_get_arr(registry,value,item);

        if (MenuReg_IsItemVisible(playerid,item))
        {
            if (menuType == MENUREG_MENU_PLAYER)
            {
                Menubox_ArmReturn(playerid);
            }

            pawn_call_public(item[E_MENUREG_CB],"ds",playerid,"");
        }
    }

    return true;
}

forward MenuReg_Resume(playerid);

public MenuReg_Resume(playerid)
{
    if (!IsPlayerConnected(playerid) || IsPlayerNPC(playerid) || Menubox_IsOpen(playerid))
    {
        return 1;
    }

    if (s_MenuRegLastGroup[playerid] >= 0)
    {
        MenuReg_OpenGroup(playerid,s_MenuRegLastGroup[playerid]);
    }
    else
    {
        MenuReg_Open(playerid,MENUREG_MENU_PLAYER);
    }

    return 1;
}

forward MenuReg_HoldCheck(playerid);

public MenuReg_HoldCheck(playerid)
{
    s_MenuRegHoldTimer[playerid] = -1;

    if (!IsPlayerConnected(playerid) || GetPlayerState(playerid) != PLAYER_STATE_DRIVER || Menubox_IsOpen(playerid))
    {
        return true;
    }

    new KEY:keys, updown, leftright;
    GetPlayerKeys(playerid,keys,updown,leftright);

    if (!(keys & MENUREG_VEH_HOLD_KEY_A) || !(keys & MENUREG_VEH_HOLD_KEY_B))
    {
        return true;
    }

    new Float:vx, Float:vy, Float:vz;
    GetVehicleVelocity(GetPlayerVehicleID(playerid),vx,vy,vz);

    if (vx * vx + vy * vy + vz * vz > (MENUREG_VEH_MAX_KMH / 181.5) * (MENUREG_VEH_MAX_KMH / 181.5))
    {
        return true;
    }

    MenuReg_Open(playerid,MENUREG_MENU_VEHICLE);
    return true;
}

forward bool:MenuReg_ChordContext(playerid);

public bool:MenuReg_ChordContext(playerid)
{
    return !IsPlayerNPC(playerid) && !IsPlayerInAnyVehicle(playerid) && s_MenuRegBlocks[playerid] == 0;
}

forward bool:MenuReg_VehHoldContext(playerid);

public bool:MenuReg_VehHoldContext(playerid)
{
    return !IsPlayerNPC(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && !Menubox_IsOpen(playerid);
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

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    MenuReg_HandleKeyStateChange(playerid,newkeys,oldkeys);
}

hook OnPlayerConnect(playerid)
{
    s_MenuRegContext[playerid] = -1;
    s_MenuRegInGroup[playerid] = false;
    s_MenuRegLastGroup[playerid] = -1;
    s_MenuRegHoldTimer[playerid] = -1;
    s_MenuRegBlocks[playerid] = 0;

    Menu_ClearCancelAction(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    MenuReg_CancelHold(playerid);
}
