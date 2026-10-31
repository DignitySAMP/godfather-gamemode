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
#define MENUBOX_DISPLAY_ITEMS (10)
#define MAX_MENU_ITEMS (100)
#define MAX_MENU_ITEM_NAME (36)
#define MAX_MENU_ITEM_COL (36)
#define MAX_MENU_ITEM_NAME_COL (28)
#define MAX_MENU_CALLBACK (64)

#define MENU_COLOUR_SELECTED (0x89AAD2FF)
#define MENU_COLOUR_UNSELECTED (0x445566FF)
#define MENU_COLOUR_MARKED (0xA3A3A3FF)
#define MENU_COLOUR_NONE (0)
#define MENU_HIGHLIGHT_PCT (45)

enum e_MENUBOX_ITEM
{
    E_MENU_NAME[MAX_MENU_ITEM_NAME],
    E_MENU_VALUE,
    E_MENU_COL[MAX_MENU_ITEM_COL],
    bool:E_MENU_HAS_COL,
    bool:E_MENU_MARKED,
    E_MENU_COLOUR,
}

static List:s_MenuList[MAX_PLAYERS];
static s_MenuItemCount[MAX_PLAYERS];
static s_MenuIndex[MAX_PLAYERS];
static s_MenuScroll[MAX_PLAYERS];
static s_MenuLastUpDown[MAX_PLAYERS];
static s_MenuLastLeftRight[MAX_PLAYERS];
static s_MenuNavRepeatTick[MAX_PLAYERS];
static s_MenuOpenTick[MAX_PLAYERS];
static bool:s_MenuFroze[MAX_PLAYERS];
static bool:s_MenuReturnArmed[MAX_PLAYERS];
static s_MenuCloseTick[MAX_PLAYERS];
static Map:s_MenuCallbacks;

#define MENUBOX_NAV_DELAY_MS (400)
#define MENUBOX_OPEN_GUARD_MS (300)
#define MENUBOX_NAV_REPEAT_MS (130)

static PlayerText:s_MenuOutline[MAX_PLAYERS] = {INVALID_PLAYER_TEXT_DRAW,...};
static PlayerText:s_MenuTitle[MAX_PLAYERS] = {INVALID_PLAYER_TEXT_DRAW,...};
static PlayerText:s_MenuItem[MAX_PLAYERS][MENUBOX_DISPLAY_ITEMS];
static PlayerText:s_MenuItemCol[MAX_PLAYERS][MENUBOX_DISPLAY_ITEMS];

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
static Menubox_Create(playerid)
{
    s_MenuOutline[playerid] = CreatePlayerTextDraw(playerid,18.000000,199.000000,"_");
    PlayerTextDrawFont(playerid,s_MenuOutline[playerid],TEXT_DRAW_FONT_1);
    PlayerTextDrawLetterSize(playerid,s_MenuOutline[playerid],0.260000,13.500000);
    PlayerTextDrawTextSize(playerid,s_MenuOutline[playerid],153.000000,0.000000);
    PlayerTextDrawSetOutline(playerid,s_MenuOutline[playerid],0);
    PlayerTextDrawSetShadow(playerid,s_MenuOutline[playerid],0);
    PlayerTextDrawAlignment(playerid,s_MenuOutline[playerid],TEXT_DRAW_ALIGN_LEFT);
    PlayerTextDrawColour(playerid,s_MenuOutline[playerid],-1);
    PlayerTextDrawBackgroundColour(playerid,s_MenuOutline[playerid],255);
    PlayerTextDrawBoxColour(playerid,s_MenuOutline[playerid],195);
    PlayerTextDrawUseBox(playerid,s_MenuOutline[playerid],true);
    PlayerTextDrawSetProportional(playerid,s_MenuOutline[playerid],true);
    PlayerTextDrawSetSelectable(playerid,s_MenuOutline[playerid],false);

    s_MenuTitle[playerid] = CreatePlayerTextDraw(playerid,18.250000,185.250000,"Menu Title");
    PlayerTextDrawFont(playerid,s_MenuTitle[playerid],TEXT_DRAW_FONT_0);
    PlayerTextDrawLetterSize(playerid,s_MenuTitle[playerid],0.550000,2.000000);
    PlayerTextDrawTextSize(playerid,s_MenuTitle[playerid],400.000000,17.000000);
    PlayerTextDrawSetOutline(playerid,s_MenuTitle[playerid],1);
    PlayerTextDrawSetShadow(playerid,s_MenuTitle[playerid],0);
    PlayerTextDrawAlignment(playerid,s_MenuTitle[playerid],TEXT_DRAW_ALIGN_LEFT);
    PlayerTextDrawColour(playerid,s_MenuTitle[playerid],-1);
    PlayerTextDrawBackgroundColour(playerid,s_MenuTitle[playerid],255);
    PlayerTextDrawBoxColour(playerid,s_MenuTitle[playerid],50);
    PlayerTextDrawUseBox(playerid,s_MenuTitle[playerid],false);
    PlayerTextDrawSetProportional(playerid,s_MenuTitle[playerid],true);
    PlayerTextDrawSetSelectable(playerid,s_MenuTitle[playerid],false);

    for (new i = 0;i < MENUBOX_DISPLAY_ITEMS;i++)
    {
        new Float:baseHeight = 208.000000 + (10.500000 * i);

        s_MenuItem[playerid][i] = CreatePlayerTextDraw(playerid,18.000000,baseHeight,"menu_item_here");
        PlayerTextDrawFont(playerid,s_MenuItem[playerid][i],TEXT_DRAW_FONT_1);
        PlayerTextDrawLetterSize(playerid,s_MenuItem[playerid][i],0.250000,1.200000);
        PlayerTextDrawTextSize(playerid,s_MenuItem[playerid][i],400.000000,17.000000);
        PlayerTextDrawSetOutline(playerid,s_MenuItem[playerid][i],0);
        PlayerTextDrawSetShadow(playerid,s_MenuItem[playerid][i],1);
        PlayerTextDrawAlignment(playerid,s_MenuItem[playerid][i],TEXT_DRAW_ALIGN_LEFT);
        PlayerTextDrawColour(playerid,s_MenuItem[playerid][i],MENU_COLOUR_SELECTED);
        PlayerTextDrawBackgroundColour(playerid,s_MenuItem[playerid][i],255);
        PlayerTextDrawBoxColour(playerid,s_MenuItem[playerid][i],50);
        PlayerTextDrawUseBox(playerid,s_MenuItem[playerid][i],false);
        PlayerTextDrawSetProportional(playerid,s_MenuItem[playerid][i],true);
        PlayerTextDrawSetSelectable(playerid,s_MenuItem[playerid][i],false);

        s_MenuItemCol[playerid][i] = CreatePlayerTextDraw(playerid,152.500000,baseHeight,"menu_col_here");
        PlayerTextDrawFont(playerid,s_MenuItemCol[playerid][i],TEXT_DRAW_FONT_1);
        PlayerTextDrawLetterSize(playerid,s_MenuItemCol[playerid][i],0.250000,1.200000);
        PlayerTextDrawTextSize(playerid,s_MenuItemCol[playerid][i],0.000000,250.000000);
        PlayerTextDrawSetOutline(playerid,s_MenuItemCol[playerid][i],0);
        PlayerTextDrawSetShadow(playerid,s_MenuItemCol[playerid][i],1);
        PlayerTextDrawAlignment(playerid,s_MenuItemCol[playerid][i],TEXT_DRAW_ALIGN_RIGHT);
        PlayerTextDrawColour(playerid,s_MenuItemCol[playerid][i],MENU_COLOUR_SELECTED);
        PlayerTextDrawBackgroundColour(playerid,s_MenuItemCol[playerid][i],255);
        PlayerTextDrawBoxColour(playerid,s_MenuItemCol[playerid][i],50);
        PlayerTextDrawUseBox(playerid,s_MenuItemCol[playerid][i],false);
        PlayerTextDrawSetProportional(playerid,s_MenuItemCol[playerid][i],true);
        PlayerTextDrawSetSelectable(playerid,s_MenuItemCol[playerid][i],false);
    }
}

static Menubox_Destroy(playerid)
{
    if (s_MenuOutline[playerid] != INVALID_PLAYER_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid,s_MenuOutline[playerid]);
        s_MenuOutline[playerid] = INVALID_PLAYER_TEXT_DRAW;
    }

    if (s_MenuTitle[playerid] != INVALID_PLAYER_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid,s_MenuTitle[playerid]);
        s_MenuTitle[playerid] = INVALID_PLAYER_TEXT_DRAW;
    }

    for (new i = 0;i < MENUBOX_DISPLAY_ITEMS;i++)
    {
        if (s_MenuItem[playerid][i] != INVALID_PLAYER_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(playerid,s_MenuItem[playerid][i]);
            s_MenuItem[playerid][i] = INVALID_PLAYER_TEXT_DRAW;
        }

        if (s_MenuItemCol[playerid][i] != INVALID_PLAYER_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(playerid,s_MenuItemCol[playerid][i]);
            s_MenuItemCol[playerid][i] = INVALID_PLAYER_TEXT_DRAW;
        }
    }
}

stock Menubox_Init()
{
    Keys_RegisterContext(KEY_SECONDARY_ATTACK,KEYS_PRIO_MENU,"Menubox_KeyContext");
    Keys_RegisterContext(KEY_SPRINT,KEYS_PRIO_MENU,"Menubox_KeyContext");
    Keys_RegisterContext(KEY_JUMP,KEYS_PRIO_MENU,"Menubox_KeyContext");
    Keys_RegisterContext(KEY_HANDBRAKE,KEYS_PRIO_MENU,"Menubox_KeyContext");

    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        for (new j = 0;j < MENUBOX_DISPLAY_ITEMS;j++)
        {
            s_MenuItem[i][j] = PlayerText:INVALID_PLAYER_TEXT_DRAW;
            s_MenuItemCol[i][j] = PlayerText:INVALID_PLAYER_TEXT_DRAW;
        }
    }
}

Menubox_Clear(playerid)
{
    if (s_MenuList[playerid] == List:0)
    {
        s_MenuList[playerid] = list_new();
    }

    list_clear(s_MenuList[playerid]);
    s_MenuIndex[playerid] = 0;
    s_MenuScroll[playerid] = 0;
    s_MenuItemCount[playerid] = 0;
    if (s_MenuCallbacks == Map:0)
    {
        s_MenuCallbacks = map_new();
    }

    map_remove(s_MenuCallbacks,playerid);
}

stock Menubox_Highlight(colour)
{
    new red = (colour >>> 24) & 0xFF;
    new green = (colour >>> 16) & 0xFF;
    new blue = (colour >>> 8) & 0xFF;
    new alpha = colour & 0xFF;

    red += ((255 - red) * MENU_HIGHLIGHT_PCT) / 100;
    green += ((255 - green) * MENU_HIGHLIGHT_PCT) / 100;
    blue += ((255 - blue) * MENU_HIGHLIGHT_PCT) / 100;

    return (red << 24) | (green << 16) | (blue << 8) | alpha;
}

static Menubox_Render(playerid)
{
    new selected = s_MenuIndex[playerid], itemsToShow = min(s_MenuItemCount[playerid],MENUBOX_DISPLAY_ITEMS);

    for (new i = 0;i < MENUBOX_DISPLAY_ITEMS;i++)
    {
        PlayerTextDrawHide(playerid,s_MenuItem[playerid][i]);
        PlayerTextDrawHide(playerid,s_MenuItemCol[playerid][i]);
    }

    for (new i = 0;i < itemsToShow;i++)
    {
        new index = s_MenuScroll[playerid] + i;

        if (index >= s_MenuItemCount[playerid])
        {
            continue;
        }

        new item[e_MENUBOX_ITEM];
        list_get_arr(s_MenuList[playerid],index,item);

        PlayerTextDrawSetString(playerid,s_MenuItem[playerid][i],item[E_MENU_NAME]);

        new rowColour = MENU_COLOUR_UNSELECTED;

        if (item[E_MENU_COLOUR] != MENU_COLOUR_NONE)
        {
            rowColour = i == selected ? Menubox_Highlight(item[E_MENU_COLOUR]) : item[E_MENU_COLOUR];
        }
        else if (item[E_MENU_MARKED])
        {
            rowColour = i == selected ? Menubox_Highlight(MENU_COLOUR_MARKED) : MENU_COLOUR_MARKED;
        }
        else if (i == selected)
        {
            rowColour = MENU_COLOUR_SELECTED;
        }

        PlayerTextDrawColour(playerid,s_MenuItem[playerid][i],rowColour);
        PlayerTextDrawShow(playerid,s_MenuItem[playerid][i]);

        if (item[E_MENU_HAS_COL])
        {
            PlayerTextDrawSetString(playerid,s_MenuItemCol[playerid][i],item[E_MENU_COL]);
            PlayerTextDrawColour(playerid,s_MenuItemCol[playerid][i],rowColour);
            PlayerTextDrawShow(playerid,s_MenuItemCol[playerid][i]);
        }
    }
}

stock bool:Menubox_AddItem(playerid,const name[],value,const col[] = "",bool:marked = false,colour = MENU_COLOUR_NONE)
{
    new index = s_MenuItemCount[playerid];

    if (index >= MAX_MENU_ITEMS)
    {
        return false;
    }

    if (s_MenuList[playerid] == List:0)
    {
        s_MenuList[playerid] = list_new();
    }

    new item[e_MENUBOX_ITEM];
    format(item[E_MENU_NAME],MAX_MENU_ITEM_NAME,"%s",name);
    item[E_MENU_VALUE] = value;
    item[E_MENU_MARKED] = marked;
    item[E_MENU_COLOUR] = colour;

    if (strlen(col) > 0)
    {
        format(item[E_MENU_COL],MAX_MENU_ITEM_COL,"%s",col);
        item[E_MENU_HAS_COL] = true;

        if (strlen(item[E_MENU_NAME]) > MAX_MENU_ITEM_NAME_COL)
        {
            item[E_MENU_NAME][MAX_MENU_ITEM_NAME_COL - 2] = EOS;
            strcat(item[E_MENU_NAME],"..");
        }
    }
    else
    {
        item[E_MENU_COL][0] = EOS;
        item[E_MENU_HAS_COL] = false;
    }

    list_add_arr(s_MenuList[playerid],item);
    s_MenuItemCount[playerid]++;
    return true;
}

stock bool:Menubox_Show(playerid,const title[],const callback[])
{
    if (s_MenuItemCount[playerid] == 0)
    {
        return false;
    }

    if (callback[0] == EOS)
    {
        return false;
    }

    if (s_MenuCallbacks == Map:0)
    {
        s_MenuCallbacks = map_new();
    }

    map_set_str(s_MenuCallbacks,playerid,callback);

    if (s_MenuOutline[playerid] == INVALID_PLAYER_TEXT_DRAW)
    {
        Menubox_Create(playerid);
    }

    new itemsToShow = min(s_MenuItemCount[playerid],MENUBOX_DISPLAY_ITEMS), Float:boxHeight = 1.000000 + (itemsToShow * 1.250000);

    PlayerTextDrawLetterSize(playerid,s_MenuOutline[playerid],0.260000,boxHeight);
    PlayerTextDrawShow(playerid,s_MenuOutline[playerid]);

    PlayerTextDrawSetString(playerid,s_MenuTitle[playerid],title);
    PlayerTextDrawShow(playerid,s_MenuTitle[playerid]);

    if (IsPlayerControllable(playerid))
    {
        s_MenuFroze[playerid] = true;
        TogglePlayerControllable(playerid,false);
    }

    s_MenuOpenTick[playerid] = GetTickCount();

    pawn_call_public("Menubox_OnOpen","d",playerid);

    Menubox_Render(playerid);
    return true;
}

stock Menubox_Hide(playerid)
{
    s_MenuCloseTick[playerid] = GetTickCount();

    if (s_MenuOutline[playerid] != INVALID_PLAYER_TEXT_DRAW)
    {
        PlayerTextDrawHide(playerid,s_MenuOutline[playerid]);
        PlayerTextDrawHide(playerid,s_MenuTitle[playerid]);

        for (new i = 0;i < MENUBOX_DISPLAY_ITEMS;i++)
        {
            PlayerTextDrawHide(playerid,s_MenuItem[playerid][i]);
            PlayerTextDrawHide(playerid,s_MenuItemCol[playerid][i]);
        }

        Menubox_Destroy(playerid);

        pawn_call_public("Menubox_OnClose","d",playerid);
    }

    if (s_MenuFroze[playerid])
    {
        s_MenuFroze[playerid] = false;
        TogglePlayerControllable(playerid,true);
    }

    Menubox_Clear(playerid);
}

stock bool:Menubox_IsOpen(playerid)
{
    if (s_MenuOutline[playerid] == INVALID_PLAYER_TEXT_DRAW)
    {
        return false;
    }

    return IsPlayerTextDrawVisible(playerid,s_MenuOutline[playerid]);
}

static Menubox_AfterDispatch(playerid,bool:response)
{
    if (!s_MenuReturnArmed[playerid])
    {
        return;
    }

    if (Menubox_IsOpen(playerid))
    {
        return;
    }

    s_MenuReturnArmed[playerid] = false;

    if (!response)
    {
        pawn_call_public("MenuReg_Resume","d",playerid);
    }
}

stock Menubox_ArmReturn(playerid)
{
    s_MenuReturnArmed[playerid] = true;
}

static Menubox_HandleKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if (!Menubox_IsOpen(playerid))
    {
        return;
    }

    if (GetTickCount() - s_MenuOpenTick[playerid] < MENUBOX_OPEN_GUARD_MS)
    {
        return;
    }

    if ((newkeys & KEY_SECONDARY_ATTACK) && !(oldkeys & KEY_SECONDARY_ATTACK))
    {
        new callback[MAX_MENU_CALLBACK];
        if (map_has_key(s_MenuCallbacks,playerid))
        {
            map_get_str(s_MenuCallbacks,playerid,callback,sizeof(callback));
        }

        PlayerPlaySound(playerid,1055);
        Menubox_Hide(playerid);
        pawn_call_public(callback,"iiisi",playerid,false,-1,"N/A",-1);
        Menubox_AfterDispatch(playerid,false);
        return;
    }

    if (((newkeys & KEY_SPRINT) && !(oldkeys & KEY_SPRINT)) || ((newkeys & KEY_JUMP) && !(oldkeys & KEY_JUMP)) || (IsPlayerInAnyVehicle(playerid) && (newkeys & KEY_HANDBRAKE) && !(oldkeys & KEY_HANDBRAKE)))
    {
        new listitem = s_MenuScroll[playerid] + s_MenuIndex[playerid], itemName[MAX_MENU_ITEM_NAME], value = -1;

        if (listitem >= 0 && listitem < s_MenuItemCount[playerid])
        {
            new item[e_MENUBOX_ITEM];
            list_get_arr(s_MenuList[playerid],listitem,item);
            format(itemName,sizeof itemName,"%s",item[E_MENU_NAME]);
            value = item[E_MENU_VALUE];
        }
        else
        {
            listitem = -1;
            format(itemName,sizeof itemName,"N/A");
        }

        new callback[MAX_MENU_CALLBACK];
        if (map_has_key(s_MenuCallbacks,playerid))
        {
            map_get_str(s_MenuCallbacks,playerid,callback,sizeof(callback));
        }

        PlayerPlaySound(playerid,1054);
        Menubox_Hide(playerid);
        pawn_call_public(callback,"iiisi",playerid,true,listitem,itemName,value);
        Menubox_AfterDispatch(playerid,true);
        return;
    }
}

static Menubox_HandleUpdate(playerid)
{
    if (!Menubox_IsOpen(playerid))
    {
        return;
    }

    new KEY:keys, updown, leftright;
    GetPlayerKeys(playerid,keys,updown,leftright);

    new lastUpDown = s_MenuLastUpDown[playerid], lastLeftRight = s_MenuLastLeftRight[playerid];

    s_MenuLastUpDown[playerid] = updown;
    s_MenuLastLeftRight[playerid] = leftright;

    new tick = GetTickCount(), bool:isUpDownFiring = false;

    if (updown != lastUpDown)
    {
        isUpDownFiring = (updown != 0);
        s_MenuNavRepeatTick[playerid] = tick + MENUBOX_NAV_DELAY_MS;
    }
    else if (updown != 0 && tick >= s_MenuNavRepeatTick[playerid])
    {
        isUpDownFiring = true;
        s_MenuNavRepeatTick[playerid] = tick + MENUBOX_NAV_REPEAT_MS;
    }

    if (!isUpDownFiring)
    {
        updown = 0;
    }

    if (leftright == lastLeftRight)
    {
        leftright = 0;
    }

    new maxDisplayLimit = MENUBOX_DISPLAY_ITEMS - 1;

    if (updown == KEY_UP)
    {
        new currentTotal = s_MenuIndex[playerid] + s_MenuScroll[playerid];

        if (currentTotal > 0)
        {
            s_MenuIndex[playerid]--;
            PlayerPlaySound(playerid,1052);

            if (s_MenuIndex[playerid] < 0)
            {
                s_MenuScroll[playerid]--;

                if (s_MenuScroll[playerid] < 0)
                {
                    s_MenuScroll[playerid] = 0;
                }

                s_MenuIndex[playerid] = 0;
            }

            Menubox_Render(playerid);
        }
    }
    else if (updown == KEY_DOWN)
    {
        new currentTotal = s_MenuIndex[playerid] + s_MenuScroll[playerid];

        if (currentTotal < s_MenuItemCount[playerid] - 1)
        {
            s_MenuIndex[playerid]++;
            PlayerPlaySound(playerid,1053);

            if (s_MenuIndex[playerid] > maxDisplayLimit)
            {
                new maxCeil = s_MenuIndex[playerid] + s_MenuScroll[playerid];

                if (maxCeil < s_MenuItemCount[playerid])
                {
                    s_MenuScroll[playerid]++;
                }

                s_MenuIndex[playerid] = maxDisplayLimit;
            }

            Menubox_Render(playerid);
        }
    }

    if (leftright == KEY_LEFT)
    {
        PlayerPlaySound(playerid,1085);
        s_MenuScroll[playerid] = 0;
        s_MenuIndex[playerid] = 0;
        Menubox_Render(playerid);
    }
    else if (leftright == KEY_RIGHT)
    {
        PlayerPlaySound(playerid,1085);

        if (s_MenuItemCount[playerid] <= MENUBOX_DISPLAY_ITEMS)
        {
            s_MenuScroll[playerid] = 0;
            s_MenuIndex[playerid] = s_MenuItemCount[playerid] - 1;
        }
        else
        {
            s_MenuScroll[playerid] = s_MenuItemCount[playerid] - MENUBOX_DISPLAY_ITEMS;
            s_MenuIndex[playerid] = maxDisplayLimit;
        }

        Menubox_Render(playerid);
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
forward Menubox_OnOpen(playerid);

public Menubox_OnOpen(playerid)
{
#pragma unused playerid
    return 1;
}

forward Menubox_OnClose(playerid);

public Menubox_OnClose(playerid)
{
#pragma unused playerid
    return 1;
}

forward bool:Menubox_KeyContext(playerid);

public bool:Menubox_KeyContext(playerid)
{
    return Menubox_IsOpen(playerid);
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
    if (IsPlayerNPC(playerid))
    {
        return;
    }

    s_MenuFroze[playerid] = false;
    Menubox_Clear(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    if (IsPlayerNPC(playerid))
    {
        return;
    }

    s_MenuReturnArmed[playerid] = false;
    Menubox_Destroy(playerid);
    Menubox_Clear(playerid);
}

hook OnPlayerDeath(playerid,killerid,WEAPON:reason)
{
    s_MenuReturnArmed[playerid] = false;

    if (Menubox_IsOpen(playerid))
    {
        Menubox_Hide(playerid);
    }
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    Menubox_HandleKeyStateChange(playerid,newkeys,oldkeys);
}

hook OnPlayerUpdate(playerid)
{
    Menubox_HandleUpdate(playerid);
}
