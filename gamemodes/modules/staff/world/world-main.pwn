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
    Command_SetDenial("tod",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD1,"   You are not authorized to use that command !");
    Command_SetDenial("fuelcars",E_COMMAND_DENIAL_LEVEL,COLOR_GREY,"   You are not an Admin ! ");
    Command_SetDenial("endround",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD1,"   you are not authorized to use that command !");
    Command_SetDenial("gmx",E_COMMAND_DENIAL_LEVEL,COLOR_GRAD1,"   You are not authorized to use that command !");
}
