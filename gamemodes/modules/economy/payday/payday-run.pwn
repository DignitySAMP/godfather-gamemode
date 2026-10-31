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
#define PAYDAY_LINES_MAX (8)
#define PAYDAY_LABEL_LEN (24)
#define PAYDAY_LABEL_RENT "Rent"
#define PAYDAY_RATE_DONOR (3)
#define PAYDAY_RATE_BASE (1)
#define PAYDAY_RATE_HOUSE_OWNER (2)
#define PAYDAY_BILL_DIVISOR (10000)
#define PAYDAY_INTEREST_DIVISOR (1000)
#define PAYDAY_MUSIC_START (1068)
#define PAYDAY_MUSIC_STOP (1069)
#define PAYDAY_MUSIC_MS (5000)

enum E_PAYDAY_LINE
{
    E_PAYDAY_LINE_LABEL[PAYDAY_LABEL_LEN],
    E_PAYDAY_LINE_AMOUNT,
    bool:E_PAYDAY_LINE_CHARGE
}

static s_PaydayLines[MAX_PLAYERS][PAYDAY_LINES_MAX][E_PAYDAY_LINE];
static s_PaydayLineCount[MAX_PLAYERS];
static bool:s_PaydayComputing[MAX_PLAYERS];
static bool:s_PaydayHouseOwner[MAX_PLAYERS];
static bool:s_PaydayUtilityHolder[MAX_PLAYERS];

forward Payday_StopMusic(playerid);

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
stock bool:Payday_AddLine(playerid,const label[],amount,bool:isCharge)
{
    if (!Util_IsValidPlayer(playerid) || !s_PaydayComputing[playerid] || amount <= 0 || s_PaydayLineCount[playerid] >= PAYDAY_LINES_MAX)
    {
        return false;
    }

    new index = s_PaydayLineCount[playerid]++;
    strcopy(s_PaydayLines[playerid][index][E_PAYDAY_LINE_LABEL],label,PAYDAY_LABEL_LEN);
    s_PaydayLines[playerid][index][E_PAYDAY_LINE_AMOUNT] = amount;
    s_PaydayLines[playerid][index][E_PAYDAY_LINE_CHARGE] = isCharge;
    return true;
}

stock bool:Payday_AddCharge(playerid,const label[],amount)
{
    return Payday_AddLine(playerid,label,amount,true);
}

stock Payday_SetHouseOwner(playerid,bool:isOwner)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_PaydayHouseOwner[playerid] = isOwner;
    }
}

stock Payday_SetUtilityHolder(playerid,bool:isHolder)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_PaydayUtilityHolder[playerid] = isHolder;
    }
}

static Payday_PlayMusic(playerid)
{
    PlayerPlaySound(playerid,PAYDAY_MUSIC_START,0.0,0.0,0.0);
    SetTimerEx("Payday_StopMusic",PAYDAY_MUSIC_MS,false,"d",playerid);
}

static Payday_ResetScratch(playerid)
{
    s_PaydayLineCount[playerid] = 0;
    s_PaydayComputing[playerid] = false;
    s_PaydayHouseOwner[playerid] = false;
    s_PaydayUtilityHolder[playerid] = false;
}

static Payday_RentTotal(playerid)
{
    new total = 0;

    for (new i = 0;i < s_PaydayLineCount[playerid];i++)
    {
        if (s_PaydayLines[playerid][i][E_PAYDAY_LINE_CHARGE] && !strcmp(s_PaydayLines[playerid][i][E_PAYDAY_LINE_LABEL],PAYDAY_LABEL_RENT,true))
        {
            total += s_PaydayLines[playerid][i][E_PAYDAY_LINE_AMOUNT];
        }
    }

    return total;
}

static Payday_Process(playerid)
{
    Payday_ResetScratch(playerid);
    pawn_call_public("Payday_OnBegin","d",playerid);

    if (!Payday_IsEligible(playerid))
    {
        SendClientMessage(playerid,COLOR_LIGHTRED,"* You haven't played long enough to obtain a PayDay.");
        return;
    }

    s_PaydayComputing[playerid] = true;
    pawn_call_public("Payday_OnCompute","d",playerid);
    s_PaydayComputing[playerid] = false;

    new level = Account_GetLevel(playerid), bool:isDonor = Account_GetDonateRank(playerid) > 0;
    new account = Bank_GetBalance(playerid);
    new rate = isDonor ? PAYDAY_RATE_DONOR : PAYDAY_RATE_BASE;

    if (s_PaydayHouseOwner[playerid])
    {
        rate += PAYDAY_RATE_HOUSE_OWNER;
    }

    new taxValue = Payday_GetTaxValue();

    if (taxValue != 0)
    {
        Payday_AddTaxPool(taxValue);
        Bank_AddBalance(playerid,-taxValue);
    }

    new checks = Payday_GetPaycheck(playerid);

    if (isDonor)
    {
        checks += checks / 2;
    }

    new ebill = s_PaydayUtilityHolder[playerid] ? (Bank_GetBalance(playerid) / PAYDAY_BILL_DIVISOR) * level : 0;
    new cash = Account_GetCash(playerid) + checks;

    for (new i = 0;i < s_PaydayLineCount[playerid];i++)
    {
        if (!s_PaydayLines[playerid][i][E_PAYDAY_LINE_CHARGE])
        {
            cash += s_PaydayLines[playerid][i][E_PAYDAY_LINE_AMOUNT];
        }
    }

    Account_SetCash(playerid,cash);

    if (Bank_GetBalance(playerid) > 0)
    {
        Bank_AddBalance(playerid,-ebill);

        if (ebill > 0)
        {
            pawn_call_public("Payday_OnBillPaid","dd",playerid,ebill);
        }
    }
    else
    {
        ebill = 0;
    }

    new interest = (Bank_GetBalance(playerid) / PAYDAY_INTEREST_DIVISOR) * rate;
    Account_SetRespect(playerid,Account_GetRespect(playerid) + 1);
    Payday_PlayMusic(playerid);
    Bank_AddBalance(playerid,interest);

    new rent = Payday_RentTotal(playerid);

    for (new i = 0;i < s_PaydayLineCount[playerid];i++)
    {
        if (s_PaydayLines[playerid][i][E_PAYDAY_LINE_CHARGE])
        {
            Bank_AddBalance(playerid,-s_PaydayLines[playerid][i][E_PAYDAY_LINE_AMOUNT]);
        }
    }

    new line[128];
    SendClientMessage(playerid,COLOR_WHITE,"|___ BANK STATEMENT ___|");
    format(line,sizeof(line),"  Paycheck: $%d   Tax Money: -$%d",checks,taxValue);
    SendClientMessage(playerid,COLOR_GRAD1,line);

    if (s_PaydayUtilityHolder[playerid])
    {
        format(line,sizeof(line),"  Electricity Bill: -$%d",ebill);
        SendClientMessage(playerid,COLOR_GRAD1,line);
    }

    format(line,sizeof(line),"  Balance: $%d",account);
    SendClientMessage(playerid,COLOR_GRAD1,line);
    format(line,sizeof(line),"  Interest Rate: 0.%d percent",rate);
    SendClientMessage(playerid,COLOR_GRAD2,line);
    format(line,sizeof(line),"  Interest Gained $%d",interest);
    SendClientMessage(playerid,COLOR_GRAD3,line);
    SendClientMessage(playerid,COLOR_GRAD4,"|--------------------------------------|");
    format(line,sizeof(line),"  New Balance: $%d",Bank_GetBalance(playerid));
    SendClientMessage(playerid,COLOR_GRAD5,line);
    format(line,sizeof(line),"  Rent: -$%d",rent);
    SendClientMessage(playerid,COLOR_GRAD5,line);

    for (new i = 0;i < s_PaydayLineCount[playerid];i++)
    {
        new bool:isCharge = s_PaydayLines[playerid][i][E_PAYDAY_LINE_CHARGE];

        if (isCharge && !strcmp(s_PaydayLines[playerid][i][E_PAYDAY_LINE_LABEL],PAYDAY_LABEL_RENT,true))
        {
            continue;
        }

        if (isCharge)
        {
            format(line,sizeof(line),"  %s: -$%d",s_PaydayLines[playerid][i][E_PAYDAY_LINE_LABEL],s_PaydayLines[playerid][i][E_PAYDAY_LINE_AMOUNT]);
        }
        else
        {
            format(line,sizeof(line),"  %s: $%d",s_PaydayLines[playerid][i][E_PAYDAY_LINE_LABEL],s_PaydayLines[playerid][i][E_PAYDAY_LINE_AMOUNT]);
        }

        SendClientMessage(playerid,COLOR_GRAD5,line);
    }

    GameTextForPlayer(playerid,"~y~PayDay~n~~w~Paycheck",5000,1);

    Payday_SetCounter(playerid,0);
    Payday_SetPaycheck(playerid,0);
    Payday_SetConnectTime(playerid,Payday_GetConnectTime(playerid) + 1);

    if (isDonor)
    {
        Payday_SetHad(playerid,Payday_GetHad(playerid) + 1);

        if (Payday_GetHad(playerid) >= PAYDAY_DONOR_EXP_EVERY)
        {
            Account_SetRespect(playerid,Account_GetRespect(playerid) + 1);
            Payday_SetHad(playerid,0);
        }
    }

    s_PaydayLineCount[playerid] = 0;
}

stock Payday_Run()
{
    foreach (new playerid : Player)
    {
        if (IsPlayerNPC(playerid) || !Player_IsReady(playerid) || !Payday_IsLoaded(playerid) || Account_GetLevel(playerid) <= 0)
        {
            continue;
        }

        Payday_Process(playerid);
    }

    pawn_call_public("Payday_OnFinished","");
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
public Payday_OnBegin(playerid)
{
    return 1;
}

public Payday_OnCompute(playerid)
{
    return 1;
}

public Payday_OnBillPaid(playerid,amount)
{
    return 1;
}

public Payday_OnFinished()
{
    return 1;
}

public Payday_StopMusic(playerid)
{
    if (IsPlayerConnected(playerid))
    {
        PlayerPlaySound(playerid,PAYDAY_MUSIC_STOP,0.0,0.0,0.0);
    }

    return 1;
}
