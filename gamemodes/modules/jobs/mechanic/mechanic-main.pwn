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

hook OnGameModeInit()
{
    Offer_RegisterAccept("repair","Mechanic_AcceptRepair");
    Offer_RegisterCancel("repair","Mechanic_CancelRepair");
    Offer_RegisterAccept("refill","Mechanic_AcceptRefill");
    Offer_RegisterCancel("refill","Mechanic_CancelRefill");
    Offer_RegisterAccept("mechanic","Mechanic_AcceptCall");
    Offer_RegisterCancel("mechanic","Mechanic_CancelCall");
    Service_Register("mechanic","Mechanic_ServiceCall");
}
