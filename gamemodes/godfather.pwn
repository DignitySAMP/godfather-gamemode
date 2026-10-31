/*
    The original The Godfather gamemode. Credits to Fear, Astro (Denver, PEN1), Tratulla, Morph and the fuel system author.
    Modernized, tested and fixed for open.mp by Dignity (PawnPlus, pawn-plus-mysql, MySQL R41-4, pp-hooks, streamer, sscanf, SmartCMD, samp-bcrypt, strlib, tdialogs, foreach, crashdetect).
*/

#pragma dynamic 2100000

#include "modules/core/includes.pwn"
#include "modules/core/definitions.pwn"
#include "modules/core/mysql.pwn"
#include "modules/util/util-header.pwn"
#include "modules/core/database.pwn"
#include "modules/core/callbacks.pwn"
#include "modules/gui/gui-header.pwn"
#include "modules/player/player-header.pwn"
#include "modules/account/account-header.pwn"
#include "modules/spawn/spawn-header.pwn"
#include "modules/player/misc/misc-header.pwn"
#include "modules/player/progress/progress-header.pwn"
#include "modules/player/licenses/licenses-header.pwn"
#include "modules/player/weapons/weapons-header.pwn"
#include "modules/economy/economy-header.pwn"
#include "modules/property/property-header.pwn"
#include "modules/player/tutorial/tutorial-header.pwn"
#include "modules/help/help-header.pwn"
#include "modules/vehicles/vehicles-header.pwn"
#include "modules/factions/factions-header.pwn"
#include "modules/law/law-header.pwn"
#include "modules/jobs/jobs-header.pwn"
#include "modules/world/hints/hints-header.pwn"
#include "modules/news/news-header.pwn"
#include "modules/jobs/drugs/drugs-header.pwn"
#include "modules/jobs/paperboy/paperboy-header.pwn"
#include "modules/families/families-header.pwn"
#include "modules/phone/phone-header.pwn"
#include "modules/irc/irc-header.pwn"
#include "modules/world/music/music-header.pwn"
#include "modules/staff/staff-header.pwn"
#include "modules/player/death/death-header.pwn"
#include "modules/social/ck/ck-header.pwn"
#include "modules/social/marriage/marriage-header.pwn"
#include "modules/world/pickups/pickups-header.pwn"
#include "modules/world/nametags/nametags-header.pwn"
#include "modules/world/casinos/casinos-header.pwn"
#include "modules/events/events-header.pwn"

main()
{
    print(" ");
    print(" ");
    print(" The Godfather: LS/SF");
    print("_____________________");
    print(" By: Fear & parts of Astro");
    print(" ");
}

public OnGameModeInit()
{
    SetGameModeText("The Godfather: LS/SF");
    EnableZoneNames(true);
    UsePlayerPedAnims();
    EnableStuntBonusForAll(false);
    DisableInteriorEnterExits();

    Boot_Run();
    return 1;
}

forward OnServerFinishLoading();
public OnServerFinishLoading()
{
    Log_Info("boot", "The Godfather %s ready - %d slots", GODFATHER_VERSION, MAX_PLAYERS);
    return 1;
}

forward UselessFunction();
public UselessFunction()
{
    return true;
}
